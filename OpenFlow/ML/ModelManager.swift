import Foundation

/// Manages model discovery, download, and storage.
/// For MVP, WhisperKit handles its own model downloads.
/// This class provides the model directory and available model list.
enum ModelManager {
    static let supportDir: URL = {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("OpenFlow/Models", isDirectory: true)
    }()

    static let availableWhisperModels: [String] = [
        "large-v3_turbo",
        "large-v3",
        "small",
        "small.en",
        "base",
        "base.en",
        "tiny",
        "tiny.en",
    ]

    static func ensureDirectoryExists() {
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
    }
}
