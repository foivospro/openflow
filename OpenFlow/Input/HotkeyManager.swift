import Cocoa
import Carbon.HIToolbox

final class HotkeyManager {
    var onHotkeyPressed: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    // Default hotkey: Control + Shift + Space
    private let hotKeyCode: UInt16 = UInt16(kVK_Space)
    private let hotModifiers: CGEventFlags = [.maskControl, .maskShift]

    func start() {
        let eventMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)

        // We need to capture `self` pointer for the C callback
        let userInfo = Unmanaged.passRetained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }

                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon).takeUnretainedValue()

                if type == .keyDown {
                    let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                    let flags = event.flags

                    if keyCode == manager.hotKeyCode &&
                       flags.contains(manager.hotModifiers) {
                        DispatchQueue.main.async {
                            manager.onHotkeyPressed?()
                        }
                        return nil // consume the event
                    }
                }

                // If the tap is disabled by the system, re-enable it
                if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                    if let tap = manager.eventTap {
                        CGEvent.tapEnable(tap: tap, enable: true)
                    }
                    return Unmanaged.passRetained(event)
                }

                return Unmanaged.passRetained(event)
            },
            userInfo: userInfo
        ) else {
            print("[HotkeyManager] Failed to create event tap. Is Accessibility enabled?")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            print("[HotkeyManager] Global hotkey registered (Ctrl+Shift+Space)")
        }
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    deinit {
        stop()
    }
}
