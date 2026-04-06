import AppKit
import CoreGraphics

enum TextInjector {
    /// Injects text into the currently focused app by:
    /// 1. Saving current clipboard
    /// 2. Setting text to clipboard
    /// 3. Simulating Cmd+V
    /// 4. Restoring original clipboard
    @MainActor
    static func inject(_ text: String) async {
        let pasteboard = NSPasteboard.general

        // Save current clipboard
        let previousContents = pasteboard.pasteboardItems?.compactMap { item -> (String, String)? in
            guard let type = item.types.first,
                  let data = item.string(forType: type) else { return nil }
            return (type.rawValue, data)
        }

        // Set our text
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        // Small delay to ensure clipboard is set
        try? await Task.sleep(for: .milliseconds(50))

        // Simulate Cmd+V
        simulatePaste()

        // Wait for paste to complete, then restore
        try? await Task.sleep(for: .milliseconds(200))

        // Restore previous clipboard
        pasteboard.clearContents()
        if let previous = previousContents {
            for (typeRaw, data) in previous {
                let type = NSPasteboard.PasteboardType(typeRaw)
                pasteboard.setString(data, forType: type)
            }
        }
    }

    private static func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)

        // Key code 0x09 = 'v'
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        keyDown?.flags = .maskCommand
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyUp?.flags = .maskCommand

        keyDown?.post(tap: .cgAnnotatedSessionEventTap)
        keyUp?.post(tap: .cgAnnotatedSessionEventTap)
    }
}
