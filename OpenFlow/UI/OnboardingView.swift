import SwiftUI

struct OnboardingView: View {
    let appState: AppState
    let permissionsManager: PermissionsManager
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to OpenFlow")
                .font(.largeTitle.bold())

            Text("Free, open-source voice dictation that runs locally on your Mac.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                permissionRow(
                    icon: "mic.fill",
                    title: "Microphone",
                    description: "To hear your voice",
                    granted: appState.hasMicrophonePermission
                )

                permissionRow(
                    icon: "hand.raised.fill",
                    title: "Accessibility",
                    description: "To type text and capture hotkeys",
                    granted: appState.hasAccessibilityPermission
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 12) {
                if !appState.hasMicrophonePermission {
                    Button("Grant Microphone Access") {
                        permissionsManager.checkMicrophone()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !appState.hasAccessibilityPermission {
                    Button("Open Accessibility Settings") {
                        permissionsManager.requestAccessibility()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !appState.needsPermissions {
                    Button("Get Started") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }

            HStack(spacing: 4) {
                Text("Hotkey:")
                    .foregroundStyle(.secondary)
                Text("Ctrl + Shift + Space")
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .font(.callout)
        }
        .padding(40)
        .frame(width: 420)
    }

    private func permissionRow(icon: String, title: String, description: String, granted: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
                .foregroundStyle(granted ? .green : .orange)

            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(description).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: granted ? "checkmark.circle.fill" : "exclamationmark.circle")
                .foregroundStyle(granted ? .green : .orange)
        }
    }
}
