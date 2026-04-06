import SwiftUI

enum FlowState: Equatable {
    case idle
    case recording
    case processing
    case injecting
}

@Observable
final class AppState {
    var flowState: FlowState = .idle
    var transcribedText: String = ""
    var isModelLoaded: Bool = false
    var modelLoadingProgress: Double = 0
    var errorMessage: String?

    var hasAccessibilityPermission: Bool = false
    var hasMicrophonePermission: Bool = false

    // Settings
    var selectedModel: String = "large-v3_turbo"
    var selectedLanguage: String = "en"
    var silenceThreshold: Double = 2.0

    var isRecording: Bool { flowState == .recording }
    var isProcessing: Bool { flowState == .processing }
    var needsPermissions: Bool { !hasAccessibilityPermission || !hasMicrophonePermission }
}
