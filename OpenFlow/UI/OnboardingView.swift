import SwiftUI

struct OnboardingView: View {
    let appState: AppState
    let permissionsManager: PermissionsManager
    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)

            // Icon
            Image(systemName: "waveform")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.primary)

            Spacer().frame(height: 16)

            Text("OpenFlow")
                .font(.system(size: 22, weight: .semibold))

            Text("Voice dictation, locally on your Mac.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            Spacer().frame(height: 32)

            // Permissions
            VStack(spacing: 0) {
                permissionRow(
                    icon: "mic.fill",
                    title: "Microphone",
                    granted: appState.hasMicrophonePermission,
                    action: { permissionsManager.checkMicrophone() }
                )

                Divider().padding(.leading, 40)

                permissionRow(
                    icon: "keyboard",
                    title: "Accessibility",
                    granted: appState.hasAccessibilityPermission,
                    action: { permissionsManager.requestAccessibility() }
                )
            }
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 32)

            Spacer().frame(height: 24)

            // Hotkey hint
            HStack(spacing: 3) {
                ForEach(["Ctrl", "Shift", "Space"], id: \.self) { key in
                    Text(key)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                Text("to start")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 4)
            }

            Spacer().frame(height: 24)

            if !appState.needsPermissions {
                Button(action: onComplete) {
                    Text("Start")
                        .font(.system(size: 13, weight: .medium))
                        .frame(width: 120)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .controlSize(.regular)
            }

            Spacer().frame(height: 32)
        }
        .frame(width: 320, height: 360)
    }

    private func permissionRow(icon: String, title: String, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .frame(width: 20)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.system(size: 13))

            Spacer()

            if granted {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.green)
            } else {
                Button("Enable") {
                    action()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
