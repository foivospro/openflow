import SwiftUI

@main
struct OpenFlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Main window: shown only for onboarding, then hidden
        Window("OpenFlow", id: "onboarding") {
            OnboardingView(
                appState: appDelegate.appState,
                permissionsManager: appDelegate.permissionsManager,
                onComplete: {
                    // Close the onboarding window
                    NSApplication.shared.keyWindow?.close()
                }
            )
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // Settings window
        Settings {
            SettingsView(appState: appDelegate.appState)
        }
    }
}
