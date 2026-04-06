import SwiftUI

struct SettingsView: View {
    let appState: AppState

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gear") }

            transcriptionTab
                .tabItem { Label("Transcription", systemImage: "waveform") }

            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 400, height: 250)
    }

    private var generalTab: some View {
        Form {
            Section("Hotkey") {
                Text("Ctrl + Shift + Space")
                    .foregroundStyle(.secondary)
                Text("Hotkey customization coming soon.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Section("Silence Detection") {
                Slider(value: Binding(
                    get: { appState.silenceThreshold },
                    set: { appState.silenceThreshold = $0 }
                ), in: 1...5, step: 0.5) {
                    Text("Auto-stop after silence: \(appState.silenceThreshold, specifier: "%.1f")s")
                }
            }
        }
        .padding()
    }

    private var transcriptionTab: some View {
        Form {
            Section("Whisper Model") {
                Picker("Model", selection: Binding(
                    get: { appState.selectedModel },
                    set: { appState.selectedModel = $0 }
                )) {
                    ForEach(ModelManager.availableWhisperModels, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }

                Text("Larger models are more accurate but slower.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Language") {
                Picker("Language", selection: Binding(
                    get: { appState.selectedLanguage },
                    set: { appState.selectedLanguage = $0 }
                )) {
                    Text("English").tag("en")
                    Text("Greek").tag("el")
                    Text("Auto-detect").tag("auto")
                }
            }
        }
        .padding()
    }

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.badge.xmark")
                .font(.system(size: 40))
                .foregroundStyle(.blue)

            Text("OpenFlow")
                .font(.title2.bold())

            Text("v0.1.0")
                .foregroundStyle(.secondary)

            Text("Open-source voice dictation for macOS.\nRuns 100% locally on your Mac.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
