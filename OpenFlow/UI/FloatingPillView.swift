import SwiftUI

struct FloatingPillView: View {
    let appState: AppState

    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer?
    @State private var waveformPhase: Double = 0

    var body: some View {
        HStack(spacing: 6) {
            // Waveform or status icon
            if appState.isRecording {
                WaveformView(phase: waveformPhase)
                    .frame(width: 20, height: 14)
            } else if appState.isProcessing {
                ProgressView()
                    .controlSize(.mini)
                    .tint(.white.opacity(0.7))
            } else {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Minimal text
            Text(statusText)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.black.opacity(0.75))
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.08), lineWidth: 0.5))
        .onChange(of: appState.flowState) { _, newState in
            if newState == .recording {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }

    private var statusText: String {
        switch appState.flowState {
        case .idle: return ""
        case .recording: return formatTime(elapsedSeconds)
        case .processing: return "..."
        case .injecting: return ""
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        elapsedSeconds = 0
        waveformPhase = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            waveformPhase += 0.15
        }
        // Separate second counter
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if appState.isRecording {
                elapsedSeconds += 1
            } else {
                t.invalidate()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Waveform animation (like Wispr's audio visualizer)

struct WaveformView: View {
    let phase: Double
    private let barCount = 4

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white.opacity(0.7))
                    .frame(width: 2, height: barHeight(for: i))
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let offset = Double(index) * 0.8
        let height = 4.0 + 10.0 * abs(sin(phase + offset))
        return height
    }
}
