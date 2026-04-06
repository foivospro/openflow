import Foundation

/// Orchestrates the full dictation flow:
/// IDLE → RECORDING → PROCESSING → INJECTING → IDLE
@MainActor
final class FlowPipeline {
    private let appState: AppState
    private let transcriptionEngine = TranscriptionEngine()
    private let audioRecorder = AudioRecorder()
    private let vad: VADProcessor

    init(appState: AppState) {
        self.appState = appState
        self.vad = VADProcessor(silenceDuration: appState.silenceThreshold)
    }

    func loadModel() async {
        do {
            try await transcriptionEngine.loadModel(name: appState.selectedModel)
            appState.isModelLoaded = true
            appState.errorMessage = nil
            print("[FlowPipeline] Model loaded successfully")
        } catch {
            appState.errorMessage = "Failed to load model: \(error.localizedDescription)"
            print("[FlowPipeline] Model load error: \(error)")
        }
    }

    func startRecording() async {
        guard appState.flowState == .idle else { return }
        guard appState.isModelLoaded else {
            appState.errorMessage = "Model not loaded yet"
            return
        }

        // Setup VAD
        vad.reset()
        vad.onSilenceDetected = { [weak self] in
            Task { @MainActor in
                await self?.stopAndProcess()
            }
        }

        // Feed audio chunks to VAD
        audioRecorder.onAudioChunk = { [weak self] samples in
            self?.vad.processBuffer(samples)
        }

        do {
            try audioRecorder.startRecording()
            appState.flowState = .recording
            appState.errorMessage = nil
            print("[FlowPipeline] Recording started (VAD auto-stop: \(appState.silenceThreshold)s)")
        } catch {
            appState.errorMessage = "Failed to start recording: \(error.localizedDescription)"
            print("[FlowPipeline] Recording error: \(error)")
        }
    }

    func stopAndProcess() async {
        guard appState.flowState == .recording else { return }

        vad.onSilenceDetected = nil
        audioRecorder.onAudioChunk = nil

        let audioData = audioRecorder.stopRecording()
        appState.flowState = .processing
        print("[FlowPipeline] Processing \(audioData.count) samples (\(String(format: "%.1f", Double(audioData.count) / 16000))s of audio)...")

        guard !audioData.isEmpty else {
            appState.flowState = .idle
            return
        }

        do {
            let text = try await transcriptionEngine.transcribe(audioArray: audioData)
            appState.transcribedText = text
            print("[FlowPipeline] Transcribed: \(text)")

            guard !text.isEmpty else {
                appState.flowState = .idle
                return
            }

            appState.flowState = .injecting
            await TextInjector.inject(text)

            appState.flowState = .idle
            appState.errorMessage = nil
            print("[FlowPipeline] Done")
        } catch {
            appState.errorMessage = "Transcription failed: \(error.localizedDescription)"
            appState.flowState = .idle
            print("[FlowPipeline] Error: \(error)")
        }
    }
}
