import AppKit

/// Reads text context from the currently focused UI element using Accessibility API.
/// Used in Flow mode to provide context to the LLM for smarter rewriting.
enum ContextReader {
    struct Context {
        let fullText: String?
        let selectedText: String?
        let appName: String?
    }

    static func readFocusedContext() -> Context {
        let systemWide = AXUIElementCreateSystemWide()

        var focusedApp: AnyObject?
        AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &focusedApp)

        let appName: String? = {
            guard let app = focusedApp else { return nil }
            var name: AnyObject?
            AXUIElementCopyAttributeValue(app as! AXUIElement, kAXTitleAttribute as CFString, &name)
            return name as? String
        }()

        var focusedElement: AnyObject?
        AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedElement)

        guard let element = focusedElement else {
            return Context(fullText: nil, selectedText: nil, appName: appName)
        }

        let axElement = element as! AXUIElement

        var value: AnyObject?
        AXUIElementCopyAttributeValue(axElement, kAXValueAttribute as CFString, &value)
        let fullText = value as? String

        var selectedValue: AnyObject?
        AXUIElementCopyAttributeValue(axElement, kAXSelectedTextAttribute as CFString, &selectedValue)
        let selectedText = selectedValue as? String

        return Context(fullText: fullText, selectedText: selectedText, appName: appName)
    }
}
