import SwiftUI
import ServiceManagement

struct SettingsView: View {
    let appState: AppState
    var permissionsManager: PermissionsManager?

    var body: some View {
        VStack(spacing: 0) {
            // Single clean list — no tabs
            Form {
                // General
                Section {
                    Toggle("Launch at login", isOn: Binding(
                        get: { appState.launchAtLogin },
                        set: { appState.setLaunchAtLogin($0) }
                    ))

                    HStack {
                        Text("Hotkey")
                        Spacer()
                        HotkeyBadge(keys: ["Ctrl", "Shift", "Space"])
                    }
                }

                // Model
                Section {
                    Picker("Model", selection: Binding(
                        get: { appState.selectedModel },
                        set: {
                            appState.selectedModel = $0
                            appState.persistSettings()
                        }
                    )) {
                        ForEach(ModelManager.availableWhisperModels, id: \.self) { model in
                            Text(modelLabel(model)).tag(model)
                        }
                    }

                    Picker("Language", selection: Binding(
                        get: { appState.selectedLanguage },
                        set: {
                            appState.selectedLanguage = $0
                            appState.persistSettings()
                        }
                    )) {
                        Text("Auto-detect").tag("auto")
                        Text("English").tag("en")
                        Text("Greek").tag("el")
                        Text("Spanish").tag("es")
                        Text("French").tag("fr")
                        Text("German").tag("de")
                        Text("Italian").tag("it")
                        Text("Portuguese").tag("pt")
                        Text("Japanese").tag("ja")
                        Text("Chinese").tag("zh")
                    }
                }

                // VAD
                Section {
                    HStack {
                        Text("Silence auto-stop")
                        Spacer()
                        Text("\(appState.silenceThreshold, specifier: "%.1f")s")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                            .font(.system(size: 12))
                    }
                    Slider(value: Binding(
                        get: { appState.silenceThreshold },
                        set: {
                            appState.silenceThreshold = $0
                            appState.persistSettings()
                        }
                    ), in: 1...5, step: 0.5)
                }

                // Permissions
                Section {
                    permissionRow("Microphone", granted: appState.hasMicrophonePermission)
                    permissionRow("Accessibility", granted: appState.hasAccessibilityPermission)
                }

                // About
                Section {
                    HStack {
                        Text("OpenFlow")
                        Spacer()
                        Text("v0.1.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Model status")
                        Spacer()
                        if appState.isModelLoaded {
                            Text("Loaded")
                                .foregroundStyle(.green)
                        } else {
                            HStack(spacing: 6) {
                                ProgressView().controlSize(.mini)
                                Text("Loading...")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 360, height: 440)
    }

    private func permissionRow(_ title: String, granted: Bool) -> some View {
        HStack {
            Text(title)
            Spacer()
            if granted {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.green)
            } else {
                Text("Not granted")
                    .font(.system(size: 12))
                    .foregroundStyle(.orange)
            }
        }
    }

    private func modelLabel(_ model: String) -> String {
        let size: String
        switch model {
        case "tiny", "tiny.en": size = "75 MB"
        case "base", "base.en": size = "150 MB"
        case "small", "small.en": size = "500 MB"
        case "large-v3": size = "3 GB"
        case "large-v3_turbo": size = "1.5 GB"
        default: size = ""
        }
        return size.isEmpty ? model : "\(model) (\(size))"
    }
}

struct HotkeyBadge: View {
    let keys: [String]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(.quaternary)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
            }
        }
    }
}
