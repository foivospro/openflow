import XCTest
@testable import OpenFlow

final class VADProcessorTests: XCTestCase {

    func testSilenceDetectedAfterDuration() {
        let expectation = expectation(description: "Silence detected")
        let vad = VADProcessor(silenceDuration: 0.1)

        vad.onSilenceDetected = {
            expectation.fulfill()
        }

        // Simulate voice first
        let voiceSamples = (0..<1600).map { _ in Float.random(in: -0.5...0.5) }
        vad.processBuffer(voiceSamples)

        // Then silence
        let silentSamples = [Float](repeating: 0.0, count: 1600)

        // Feed silence repeatedly over time
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            vad.processBuffer(silentSamples)
            if vad.onSilenceDetected == nil {
                timer.invalidate()
            }
        }

        waitForExpectations(timeout: 2.0)
    }

    func testNoSilenceWhileSpeaking() {
        let vad = VADProcessor(silenceDuration: 1.0)
        var silenceDetected = false

        vad.onSilenceDetected = {
            silenceDetected = true
        }

        // Feed voice continuously
        let voiceSamples = (0..<1600).map { _ in Float.random(in: -0.5...0.5) }
        for _ in 0..<10 {
            vad.processBuffer(voiceSamples)
        }

        XCTAssertFalse(silenceDetected)
    }

    func testResetClearsSpeakingState() {
        let vad = VADProcessor(silenceDuration: 0.01)
        var silenceCount = 0

        vad.onSilenceDetected = {
            silenceCount += 1
        }

        // Voice then silence
        let voiceSamples = (0..<1600).map { _ in Float.random(in: -0.5...0.5) }
        vad.processBuffer(voiceSamples)

        vad.reset()

        // After reset, silence should not trigger (isSpeaking was reset to false)
        let silentSamples = [Float](repeating: 0.0, count: 1600)
        vad.processBuffer(silentSamples)

        XCTAssertEqual(silenceCount, 0)
    }

    func testComputeRMSWithEmptyInput() {
        let vad = VADProcessor(silenceDuration: 1.0)
        var silenceDetected = false

        vad.onSilenceDetected = {
            silenceDetected = true
        }

        // Empty buffer should not crash or trigger
        vad.processBuffer([])
        XCTAssertFalse(silenceDetected)
    }
}
