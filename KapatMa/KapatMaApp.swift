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
    var awakeManager = AwakeManager()
    var quotesManager = QuotesManager()
    var themeManager = ThemeManager()
    var brightnessManager = BrightnessManager()
    var localizationManager = LocalizationManager.shared
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
        popover.contentSize = NSSize(width: 370, height: 620)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MainPopoverView(
                awakeManager: awakeManager,
                quotesManager: quotesManager,
                themeManager: themeManager,
                brightnessManager: brightnessManager,
                localizationManager: localizationManager
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

        if awakeManager.isActive {
            let remaining = awakeManager.formattedRemaining
            button.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Active")
            button.image?.isTemplate = true
            button.title = awakeManager.isInfinite ? " ∞" : " \(remaining)"
        } else {
            button.image = NSImage(systemSymbolName: "cup.and.saucer", accessibilityDescription: "Inactive")
            button.image?.isTemplate = true
            button.title = ""
        }
        button.imagePosition = .imageLeading
    }

    func applicationWillTerminate(_ notification: Notification) {
        awakeManager.stop()
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
