import SwiftUI

struct FloatingPillView: View {
    let appState: AppState

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 8) {
            icon
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)

            if appState.isProcessing {
                ProgressView()
                    .controlSize(.small)
                    .tint(.white)
            }

            Text(statusText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        .scaleEffect(appState.isRecording ? pulseScale : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch appState.flowState {
        case .recording:
            Image(systemName: "mic.fill")
                .symbolEffect(.pulse, isActive: true)
        case .processing:
            Image(systemName: "brain")
        case .injecting:
            Image(systemName: "text.cursor")
        case .idle:
            Image(systemName: "mic.fill")
        }
    }

    private var statusText: String {
        switch appState.flowState {
        case .idle: return "Ready"
        case .recording: return "Listening..."
        case .processing: return "Thinking..."
        case .injecting: return "Typing..."
        }
    }

    private var backgroundColor: Color {
        switch appState.flowState {
        case .recording: return .red
        case .processing: return .orange
        case .injecting: return .blue
        case .idle: return .gray
        }
    }
}
