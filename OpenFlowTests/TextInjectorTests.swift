import XCTest
import AppKit
@testable import OpenFlow

final class TextInjectorTests: XCTestCase {

    @MainActor
    func testClipboardRestoredAfterInjection() async {
        let pasteboard = NSPasteboard.general

        // Set known clipboard content
        pasteboard.clearContents()
        pasteboard.setString("original content", forType: .string)

        // Inject (paste won't actually work in test, but clipboard logic runs)
        await TextInjector.inject("test transcription")

        // After injection, clipboard should be restored
        // Note: there's a small timing window, but the restore should have run
        try? await Task.sleep(for: .milliseconds(300))

        let restored = pasteboard.string(forType: .string)
        XCTAssertEqual(restored, "original content")
    }
}
