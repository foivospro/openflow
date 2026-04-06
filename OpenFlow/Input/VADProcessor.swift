import Foundation

/// Simple energy-based Voice Activity Detection.
/// Detects silence by monitoring RMS energy of audio buffers.
final class VADProcessor {
    private let silenceThreshold: Float = 0.01
    private let silenceDuration: TimeInterval

    private var lastVoiceTime: Date = .now
    private var isSpeaking: Bool = false

    var onSilenceDetected: (() -> Void)?

    init(silenceDuration: TimeInterval = 2.0) {
        self.silenceDuration = silenceDuration
    }

    func processBuffer(_ samples: [Float]) {
        let rms = computeRMS(samples)

        if rms > silenceThreshold {
            lastVoiceTime = .now
            isSpeaking = true
        } else if isSpeaking {
            let elapsed = Date.now.timeIntervalSince(lastVoiceTime)
            if elapsed >= silenceDuration {
                isSpeaking = false
                onSilenceDetected?()
            }
        }
    }

    func reset() {
        lastVoiceTime = .now
        isSpeaking = false
    }

    private func computeRMS(_ samples: [Float]) -> Float {
        guard !samples.isEmpty else { return 0 }
        let sumOfSquares = samples.reduce(Float(0)) { $0 + $1 * $1 }
        return sqrt(sumOfSquares / Float(samples.count))
    }
}
