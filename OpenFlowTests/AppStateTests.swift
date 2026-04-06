import XCTest
@testable import OpenFlow

final class AppStateTests: XCTestCase {

    func testInitialState() {
        let state = AppState()

        XCTAssertEqual(state.flowState, .idle)
        XCTAssertEqual(state.transcribedText, "")
        XCTAssertFalse(state.isModelLoaded)
        XCTAssertNil(state.errorMessage)
        XCTAssertFalse(state.hasAccessibilityPermission)
        XCTAssertFalse(state.hasMicrophonePermission)
    }

    func testIsRecordingDerived() {
        let state = AppState()

        XCTAssertFalse(state.isRecording)

        state.flowState = .recording
        XCTAssertTrue(state.isRecording)

        state.flowState = .processing
        XCTAssertFalse(state.isRecording)
    }

    func testIsProcessingDerived() {
        let state = AppState()

        XCTAssertFalse(state.isProcessing)

        state.flowState = .processing
        XCTAssertTrue(state.isProcessing)
    }

    func testNeedsPermissions() {
        let state = AppState()

        XCTAssertTrue(state.needsPermissions)

        state.hasMicrophonePermission = true
        XCTAssertTrue(state.needsPermissions)

        state.hasAccessibilityPermission = true
        XCTAssertFalse(state.needsPermissions)
    }

    func testFlowStateEquatable() {
        XCTAssertEqual(FlowState.idle, FlowState.idle)
        XCTAssertEqual(FlowState.recording, FlowState.recording)
        XCTAssertNotEqual(FlowState.idle, FlowState.recording)
    }

    func testDefaultSettings() {
        let state = AppState()

        XCTAssertEqual(state.selectedModel, "large-v3_turbo")
        XCTAssertEqual(state.selectedLanguage, "en")
        XCTAssertEqual(state.silenceThreshold, 2.0)
    }
}
