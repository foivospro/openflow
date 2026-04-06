import SwiftUI

@main
struct OpenFlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("OpenFlow", id: "onboarding") {
            OnboardingView(
                appState: appDelegate.appState,
                permissionsManager: appDelegate.permissionsManager,
                onComplete: {
                    NSApplication.shared.keyWindow?.close()
                }
            )
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        Settings {
            SettingsView(
                appState: appDelegate.appState,
                permissionsManager: appDelegate.permissionsManager
            )
        }
    }
}
