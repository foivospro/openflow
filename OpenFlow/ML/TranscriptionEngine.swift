import WhisperKit
import Foundation

actor TranscriptionEngine {
    private var whisperKit: WhisperKit?

    var isLoaded: Bool { whisperKit != nil }

    func loadModel(name: String = "large-v3_turbo") async throws {
        let config = WhisperKitConfig(model: name)
        whisperKit = try await WhisperKit(config)
        print("[TranscriptionEngine] Model '\(name)' loaded")
    }

    func transcribe(audioArray: [Float]) async throws -> String {
        guard let wk = whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }

        let results = try await wk.transcribe(audioArray: audioArray)
        let text = results.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return text
    }

    func unloadModel() {
        whisperKit = nil
    }

    enum TranscriptionError: LocalizedError {
        case modelNotLoaded

        var errorDescription: String? {
            switch self {
            case .modelNotLoaded: return "Whisper model is not loaded"
            }
        }
    }
}
