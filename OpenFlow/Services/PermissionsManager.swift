import AVFoundation
import AppKit

final class PermissionsManager {
    private let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func checkAll() {
        checkAccessibility()
        checkMicrophone()
    }

    func checkAccessibility() {
        let trusted = AXIsProcessTrusted()
        Task { @MainActor in
            appState.hasAccessibilityPermission = trusted
        }
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        Task { @MainActor in
            appState.hasAccessibilityPermission = trusted
        }
    }

    func checkMicrophone() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            Task { @MainActor in
                appState.hasMicrophonePermission = true
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                Task { @MainActor in
                    self?.appState.hasMicrophonePermission = granted
                }
            }
        default:
            Task { @MainActor in
                appState.hasMicrophonePermission = false
            }
        }
    }

    func openSystemSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}
