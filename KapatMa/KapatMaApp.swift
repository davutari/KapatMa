import SwiftUI

@main
struct KapatMaApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var caffeineManager = CaffeineManager()
    var quotesManager = QuotesManager()
    var themeManager = ThemeManager()
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            updateMenuBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 370, height: 540)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MainPopoverView(
                caffeineManager: caffeineManager,
                quotesManager: quotesManager,
                themeManager: themeManager
            )
        )

        // Start timer to update menu bar
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateMenuBarIcon()
        }

        // Register global hotkey (Cmd+Shift+K)
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 40 { // K key
                self?.togglePopover()
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.modifierFlags.contains([.command, .shift]) && event.keyCode == 40 {
                self?.togglePopover()
                return nil
            }
            return event
        }
    }

    func updateMenuBarIcon() {
        guard let button = statusItem.button else { return }

        if caffeineManager.isActive {
            let remaining = caffeineManager.formattedRemaining
            let icon = caffeineManager.isInfinite ? "🔓∞" : "🔓 \(remaining)"
            button.title = icon
        } else {
            button.title = "🔒"
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        caffeineManager.stop()
    }

    @objc func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
