import Foundation
import CoreGraphics

// MARK: - External Display Model

struct ExternalDisplay: Identifiable {
    let id: CGDirectDisplayID
    let name: String
    var brightness: Int       // 16–100 percentage
}

// MARK: - Brightness Manager

class BrightnessManager: ObservableObject {
    @Published var displays: [ExternalDisplay] = []

    private var pollTimer: Timer?
    private var writeWorkItems: [CGDirectDisplayID: DispatchWorkItem] = [:]

    init() {
        refreshDisplays()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.detectChanges()
        }
    }

    deinit {
        pollTimer?.invalidate()
    }

    // MARK: - Public API

    func refreshDisplays() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let ids = Self.externalDisplayIDs()
            var result: [ExternalDisplay] = []

            for displayID in ids {
                let name = Self.getDisplayName(displayID)
                let brightness = Self.readGammaBrightness(displayID)
                result.append(ExternalDisplay(
                    id: displayID, name: name,
                    brightness: brightness
                ))
            }

            DispatchQueue.main.async {
                self?.displays = result
            }
        }
    }

    func setBrightness(_ percentage: Int, for displayID: CGDirectDisplayID) {
        guard let idx = displays.firstIndex(where: { $0.id == displayID }) else { return }
        let clamped = max(16, min(100, percentage))
        displays[idx].brightness = clamped

        // Debounce writes (50ms)
        writeWorkItems[displayID]?.cancel()
        let item = DispatchWorkItem {
            Self.setGammaBrightness(displayID, percentage: clamped)
        }
        writeWorkItems[displayID] = item
        DispatchQueue.global(qos: .userInitiated).asyncAfter(
            deadline: .now() + 0.05, execute: item
        )
    }

    // MARK: - Display Detection

    private func detectChanges() {
        let current = Set(displays.map { $0.id })
        let live = Set(Self.externalDisplayIDs())
        if current != live { refreshDisplays() }
    }

    private static func externalDisplayIDs() -> [CGDirectDisplayID] {
        var ids = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        CGGetOnlineDisplayList(16, &ids, &count)
        return Array(ids[0..<Int(count)]).filter { CGDisplayIsBuiltin($0) == 0 }
    }

    private static func getDisplayName(_ displayID: CGDirectDisplayID) -> String {
        // Use CoreGraphics display info
        if let info = CoreGraphics.CGDisplayCopyDisplayMode(displayID) {
            let w = info.width
            let h = info.height
            return "\(LocalizationManager.shared.s(.externalMonitor)) (\(w)x\(h))"
        }
        return LocalizationManager.shared.s(.externalMonitor)
    }

    // MARK: - Gamma-based Brightness

    /// Read the current effective brightness from the display's gamma table.
    /// Returns 16–100 percentage.
    private static func readGammaBrightness(_ displayID: CGDirectDisplayID) -> Int {
        var redMin: CGGammaValue = 0, redMax: CGGammaValue = 0, redGamma: CGGammaValue = 0
        var greenMin: CGGammaValue = 0, greenMax: CGGammaValue = 0, greenGamma: CGGammaValue = 0
        var blueMin: CGGammaValue = 0, blueMax: CGGammaValue = 0, blueGamma: CGGammaValue = 0

        let err = CGGetDisplayTransferByFormula(
            displayID,
            &redMin, &redMax, &redGamma,
            &greenMin, &greenMax, &greenGamma,
            &blueMin, &blueMax, &blueGamma
        )
        guard err == .success else { return 100 }

        let avg = (redMax + greenMax + blueMax) / 3.0
        return max(16, min(100, Int(avg * 100)))
    }

    /// Set brightness via gamma table manipulation.
    /// percentage: 16 = very dim, 100 = normal brightness.
    private static func setGammaBrightness(_ displayID: CGDirectDisplayID, percentage: Int) {
        let factor = Float(max(16, min(100, percentage))) / 100.0

        CGSetDisplayTransferByFormula(
            displayID,
            0, CGGammaValue(factor), 1.0,  // red:   min, max, gamma
            0, CGGammaValue(factor), 1.0,  // green: min, max, gamma
            0, CGGammaValue(factor), 1.0   // blue:  min, max, gamma
        )
    }
}
