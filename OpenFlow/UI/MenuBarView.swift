import SwiftUI

struct MenuBarView: View {
    let appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(statusText, systemImage: statusIcon)
                .foregroundStyle(statusColor)

            Divider()

            if let error = appState.errorMessage {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if !appState.transcribedText.isEmpty {
                Text("Last: \(appState.transcribedText)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Divider()

            Label(
                appState.isModelLoaded ? "Model: \(appState.selectedModel)" : "Loading model...",
                systemImage: appState.isModelLoaded ? "brain" : "arrow.down.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 240)
    }

    private var statusText: String {
        switch appState.flowState {
        case .idle: return "Ready — Ctrl+Shift+Space"
        case .recording: return "Recording..."
        case .processing: return "Processing..."
        case .injecting: return "Typing..."
        }
    }

    private var statusIcon: String {
        switch appState.flowState {
        case .idle: return "mic.fill"
        case .recording: return "waveform"
        case .processing: return "brain"
        case .injecting: return "text.cursor"
        }
    }

    private var statusColor: Color {
        switch appState.flowState {
        case .idle: return .primary
        case .recording: return .red
        case .processing: return .orange
        case .injecting: return .blue
        }
    }
}
