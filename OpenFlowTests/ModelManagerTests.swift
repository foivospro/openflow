import XCTest
@testable import OpenFlow

final class ModelManagerTests: XCTestCase {

    func testAvailableModelsNotEmpty() {
        XCTAssertFalse(ModelManager.availableWhisperModels.isEmpty)
    }

    func testDefaultModelIsAvailable() {
        let state = AppState()
        XCTAssertTrue(ModelManager.availableWhisperModels.contains(state.selectedModel))
    }

    func testSupportDirectoryPath() {
        let path = ModelManager.supportDir.path(percentEncoded: false)
        XCTAssertTrue(path.contains("Application Support/OpenFlow/Models"),
                      "Path was: \(path)")
    }

    func testEnsureDirectoryCreation() {
        ModelManager.ensureDirectoryExists()
        let path = ModelManager.supportDir.path(percentEncoded: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path),
                      "Directory should exist at: \(path)")

        // Cleanup
        try? FileManager.default.removeItem(at: ModelManager.supportDir)
    }
}
