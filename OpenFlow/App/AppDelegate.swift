import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var pillWindow: NSPanel?

    let appState = AppState()
    lazy var permissionsManager = PermissionsManager(appState: appState)
    lazy var hotkeyManager = HotkeyManager()
    lazy var pipeline = FlowPipeline(appState: appState)

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        permissionsManager.checkAll()

        hotkeyManager.onHotkeyPressed = { [weak self] in
            self?.handleHotkey()
        }
        hotkeyManager.start()

        Task {
            await pipeline.loadModel()
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "OpenFlow")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "OpenFlow", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let statusMenuItem = NSMenuItem(title: "Ready", action: nil, keyEquivalent: "")
        statusMenuItem.tag = 100
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit OpenFlow", action: #selector(quit), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func handleHotkey() {
        Task { @MainActor in
            switch appState.flowState {
            case .idle:
                await pipeline.startRecording()
                showPill()
            case .recording:
                await pipeline.stopAndProcess()
                hidePill()
            case .processing, .injecting:
                break
            }
        }
    }

    private func showPill() {
        if pillWindow == nil {
            let pill = FloatingPillView(appState: appState)
            let hostingView = NSHostingView(rootView: pill)
            hostingView.frame = NSRect(x: 0, y: 0, width: 140, height: 40)

            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 140, height: 40),
                styleMask: [.nonactivatingPanel, .hudWindow],
                backing: .buffered,
                defer: false
            )
            panel.level = .floating
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = true
            panel.contentView = hostingView
            panel.isMovableByWindowBackground = true
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            // Position near top-center of screen
            if let screen = NSScreen.main {
                let screenFrame = screen.visibleFrame
                let x = screenFrame.midX - 70
                let y = screenFrame.maxY - 60
                panel.setFrameOrigin(NSPoint(x: x, y: y))
            }

            pillWindow = panel
        }

        pillWindow?.orderFront(nil)
    }

    private func hidePill() {
        // Delay hiding so user can see the processing state
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            if appState.flowState == .idle {
                pillWindow?.orderOut(nil)
            }
        }
    }

    @objc private func openSettings() {
        // TODO: Phase 2 — open settings window
    }

    @objc private func quit() {
        hotkeyManager.stop()
        NSApplication.shared.terminate(nil)
    }
}
