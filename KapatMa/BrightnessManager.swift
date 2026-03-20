import Foundation
import CoreGraphics

// MARK: - External Display Model

struct ExternalDisplay: Identifiable {
    let id: CGDirectDisplayID
    let name: String
    var brightness: Int       // 0–100 percentage
    let maxBrightness: Int    // raw DDC max value
    let supportsDDC: Bool     // true if DDC/CI worked
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
                var cur: UInt16 = 0
                var maxVal: UInt16 = 0

                if DDCReadBrightness(displayID, &cur, &maxVal) {
                    let pct = maxVal > 0
                        ? min(100, max(0, Int(cur) * 100 / Int(maxVal)))
                        : Int(cur)
                    result.append(ExternalDisplay(
                        id: displayID, name: name,
                        brightness: pct, maxBrightness: Int(maxVal),
                        supportsDDC: true
                    ))
                } else {
                    // DDC not supported — use gamma overlay, start at 100%
                    let gammaBrightness = Self.readGammaBrightness(displayID)
                    result.append(ExternalDisplay(
                        id: displayID, name: name,
                        brightness: gammaBrightness, maxBrightness: 100,
                        supportsDDC: false
                    ))
                }
            }

            DispatchQueue.main.async {
                self?.displays = result
            }
        }
    }

    func setBrightness(_ percentage: Int, for displayID: CGDirectDisplayID) {
        guard let idx = displays.firstIndex(where: { $0.id == displayID }) else { return }
        let clamped = max(0, min(100, percentage))
        displays[idx].brightness = clamped

        let usesDDC = displays[idx].supportsDDC

        // Debounce writes (50ms)
        writeWorkItems[displayID]?.cancel()
        let maxVal = displays[idx].maxBrightness
        let item = DispatchWorkItem {
            if usesDDC {
                let raw = UInt16(clamped * maxVal / 100)
                DDCWriteBrightness(displayID, raw)
            } else {
                Self.setGammaBrightness(displayID, percentage: clamped)
            }
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

    static func externalDisplayIDs() -> [CGDirectDisplayID] {
        var ids = [CGDirectDisplayID](repeating: 0, count: 16)
        var count: UInt32 = 0
        CGGetOnlineDisplayList(16, &ids, &count)
        return Array(ids[0..<Int(count)]).filter { CGDisplayIsBuiltin($0) == 0 }
    }

    private static func getDisplayName(_ displayID: CGDirectDisplayID) -> String {
        guard let cName = DDCGetDisplayName(displayID) else {
            return LocalizationManager.shared.s(.externalMonitor)
        }
        let name = String(cString: cName)
        free(cName)
        return name
    }

    // MARK: - Gamma-based Brightness (Fallback)

    /// Read the current effective brightness from the display's gamma table.
    /// Returns 0–100 percentage.
    static func readGammaBrightness(_ displayID: CGDirectDisplayID) -> Int {
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

        // The "max" channel values represent brightness (1.0 = full, 0.0 = black)
        let avg = (redMax + greenMax + blueMax) / 3.0
        return max(0, min(100, Int(avg * 100)))
    }

    /// Set brightness via gamma table manipulation.
    /// percentage: 0 = black screen, 100 = normal brightness.
    static func setGammaBrightness(_ displayID: CGDirectDisplayID, percentage: Int) {
        let factor = Float(max(0, min(100, percentage))) / 100.0

        CGSetDisplayTransferByFormula(
            displayID,
            0, CGGammaValue(factor), 1.0,  // red:   min, max, gamma
            0, CGGammaValue(factor), 1.0,  // green: min, max, gamma
            0, CGGammaValue(factor), 1.0   // blue:  min, max, gamma
        )
    }
}
