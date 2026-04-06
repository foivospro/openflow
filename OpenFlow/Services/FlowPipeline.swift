import Foundation

/// Orchestrates the full dictation flow:
/// IDLE → RECORDING → PROCESSING → INJECTING → IDLE
@MainActor
final class FlowPipeline {
    private let appState: AppState
    private let transcriptionEngine = TranscriptionEngine()
    private let audioRecorder = AudioRecorder()

    init(appState: AppState) {
        self.appState = appState
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

        do {
            try audioRecorder.startRecording()
            appState.flowState = .recording
            appState.errorMessage = nil
            print("[FlowPipeline] Recording started")
        } catch {
            appState.errorMessage = "Failed to start recording: \(error.localizedDescription)"
            print("[FlowPipeline] Recording error: \(error)")
        }
    }

    func stopAndProcess() async {
        guard appState.flowState == .recording else { return }

        let audioData = audioRecorder.stopRecording()
        appState.flowState = .processing
        print("[FlowPipeline] Processing \(audioData.count) samples...")

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

            // Inject into focused app
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
