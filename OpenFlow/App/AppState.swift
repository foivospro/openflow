import SwiftUI
import ServiceManagement

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

    // Settings (persisted via @AppStorage in SettingsView)
    var selectedModel: String = UserDefaults.standard.string(forKey: "selectedModel") ?? "large-v3_turbo"
    var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
    var silenceThreshold: Double = UserDefaults.standard.object(forKey: "silenceThreshold") as? Double ?? 2.0
    var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled

    var isRecording: Bool { flowState == .recording }
    var isProcessing: Bool { flowState == .processing }
    var needsPermissions: Bool { !hasAccessibilityPermission || !hasMicrophonePermission }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            launchAtLogin = enabled
        } catch {
            print("[AppState] Launch at login error: \(error)")
        }
    }

    func persistSettings() {
        UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
        UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        UserDefaults.standard.set(silenceThreshold, forKey: "silenceThreshold")
    }
}
