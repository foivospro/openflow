import AppKit
import SwiftUI
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var pillWindow: NSPanel?
    private var stateObservation: Any?

    let appState = AppState()
    lazy var permissionsManager = PermissionsManager(appState: appState)
    lazy var hotkeyManager = HotkeyManager()
    lazy var pipeline = FlowPipeline(appState: appState)

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        permissionsManager.checkAll()
        observeState()

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
        menu.delegate = self
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

    private func observeState() {
        // Update menu bar icon and pill based on state changes
        // Using a polling timer since @Observable doesn't bridge to KVO easily here
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        // Update menu bar icon
        let iconName: String
        switch appState.flowState {
        case .idle: iconName = "mic.fill"
        case .recording: iconName = "mic.badge.xmark"
        case .processing: iconName = "brain"
        case .injecting: iconName = "text.cursor"
        }
        statusItem.button?.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "OpenFlow")

        // Update status text in menu
        if let statusItem = statusItem.menu?.item(withTag: 100) {
            switch appState.flowState {
            case .idle:
                statusItem.title = appState.isModelLoaded ? "Ready — Ctrl+Shift+Space" : "Loading model..."
            case .recording:
                statusItem.title = "Recording..."
            case .processing:
                statusItem.title = "Processing..."
            case .injecting:
                statusItem.title = "Typing..."
            }
        }

        // Auto-hide pill when done
        if appState.flowState == .idle {
            pillWindow?.orderOut(nil)
        }
    }

    private func handleHotkey() {
        Task { @MainActor in
            switch appState.flowState {
            case .idle:
                await pipeline.startRecording()
                showPill()
            case .recording:
                showPillProcessing()
                await pipeline.stopAndProcess()
            case .processing, .injecting:
                break
            }
        }
    }

    private func showPill() {
        if pillWindow == nil {
            createPillWindow()
        }
        pillWindow?.orderFront(nil)
    }

    private func showPillProcessing() {
        // Keep pill visible during processing (state change will update the view)
        pillWindow?.orderFront(nil)
    }

    private func createPillWindow() {
        let pill = FloatingPillView(appState: appState)
        let hostingView = NSHostingView(rootView: pill)
        hostingView.frame = NSRect(x: 0, y: 0, width: 100, height: 32)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 32),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.contentView = hostingView
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Position at top-center, just below the menu bar
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - 50
            let y = screenFrame.maxY - 8
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        pillWindow = panel
    }

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    @objc private func quit() {
        hotkeyManager.stop()
        NSApplication.shared.terminate(nil)
    }
}

extension AppDelegate: NSMenuDelegate {
    nonisolated func menuNeedsUpdate(_ menu: NSMenu) {
        // Menu items update via the timer-based state observation
    }
}
