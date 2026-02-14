import SwiftUI

// MARK: - Color Palettes

enum ColorPalette: String, CaseIterable, Identifiable {
    case espresso = "Espresso"
    case ocean = "Okyanus"
    case sunset = "Gün Batımı"
    case forest = "Orman"
    case lavender = "Lavanta"
    case cherry = "Vişne"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .espresso: return "☕"
        case .ocean: return "🌊"
        case .sunset: return "🌅"
        case .forest: return "🌿"
        case .lavender: return "💜"
        case .cherry: return "🍒"
        }
    }

    // Primary accent color
    var accent: Color {
        switch self {
        case .espresso: return Color(hex: "D97706")
        case .ocean: return Color(hex: "0EA5E9")
        case .sunset: return Color(hex: "F97316")
        case .forest: return Color(hex: "22C55E")
        case .lavender: return Color(hex: "A78BFA")
        case .cherry: return Color(hex: "F43F5E")
        }
    }

    // Secondary accent (for gradients)
    var accentSecondary: Color {
        switch self {
        case .espresso: return Color(hex: "B45309")
        case .ocean: return Color(hex: "6366F1")
        case .sunset: return Color(hex: "EF4444")
        case .forest: return Color(hex: "059669")
        case .lavender: return Color(hex: "8B5CF6")
        case .cherry: return Color(hex: "E11D48")
        }
    }

    // Glow / shadow color
    var glow: Color {
        accent.opacity(0.4)
    }
}

// MARK: - Theme Mode

enum ThemeMode: String, CaseIterable, Identifiable {
    case system = "Sistem"
    case light = "Aydınlık"
    case dark = "Karanlık"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .system: return "💻"
        case .light: return "☀️"
        case .dark: return "🌙"
        }
    }
}

// MARK: - Theme

struct AppTheme {
    let mode: ThemeMode
    let palette: ColorPalette
    let isDark: Bool

    // Backgrounds
    var popoverBg: Color {
        isDark ? Color(hex: "0F1220") : Color(hex: "FAFBFE")
    }
    var cardBg: Color {
        isDark ? Color(hex: "161B2E") : Color(hex: "F1F3F9")
    }
    var elevatedBg: Color {
        isDark ? Color(hex: "1C2237") : Color(hex: "FFFFFF")
    }

    // Text
    var textPrimary: Color {
        isDark ? Color(hex: "F1F5F9") : Color(hex: "0F172A")
    }
    var textSecondary: Color {
        isDark ? Color(hex: "94A3B8") : Color(hex: "64748B")
    }
    var textTertiary: Color {
        isDark ? Color(hex: "475569") : Color(hex: "94A3B8")
    }

    // Borders
    var border: Color {
        isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }
    var borderSubtle: Color {
        isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.04)
    }

    // Accent shortcuts
    var accent: Color { palette.accent }
    var accentSecondary: Color { palette.accentSecondary }
    var accentBg: Color { palette.accent.opacity(isDark ? 0.1 : 0.08) }
    var accentBorder: Color { palette.accent.opacity(isDark ? 0.2 : 0.15) }

    // Stop button
    var stopBg: Color { Color(hex: "EF4444").opacity(isDark ? 0.12 : 0.08) }
    var stopBorder: Color { Color(hex: "EF4444").opacity(isDark ? 0.2 : 0.15) }
    var stopText: Color { Color(hex: "EF4444") }

    // Active indicator
    var activeBg: Color { Color(hex: "22C55E").opacity(isDark ? 0.12 : 0.08) }
    var activeText: Color { Color(hex: "22C55E") }
    var activeDot: Color { Color(hex: "22C55E") }

    // Progress ring
    var ringTrack: Color {
        isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }

    // Shadows
    var popoverShadow: Color {
        isDark ? Color.black.opacity(0.6) : Color.black.opacity(0.15)
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    @Published var mode: ThemeMode {
        didSet { save(); updateTheme() }
    }
    @Published var palette: ColorPalette {
        didSet { save(); updateTheme() }
    }
    @Published var theme: AppTheme

    private let defaults = UserDefaults.standard

    init() {
        let savedMode = ThemeMode(rawValue: UserDefaults.standard.string(forKey: "themeMode") ?? "") ?? .system
        let savedPalette = ColorPalette(rawValue: UserDefaults.standard.string(forKey: "themePalette") ?? "") ?? .espresso

        self.mode = savedMode
        self.palette = savedPalette
        self.theme = AppTheme(mode: savedMode, palette: savedPalette, isDark: ThemeManager.resolveIsDark(savedMode))

        // Observe system appearance changes
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(systemAppearanceChanged),
            name: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }

    @objc private func systemAppearanceChanged() {
        if mode == .system {
            updateTheme()
        }
    }

    func updateTheme() {
        let isDark = ThemeManager.resolveIsDark(mode)
        theme = AppTheme(mode: mode, palette: palette, isDark: isDark)
    }

    static func resolveIsDark(_ mode: ThemeMode) -> Bool {
        switch mode {
        case .dark: return true
        case .light: return false
        case .system:
            return NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
    }

    private func save() {
        defaults.set(mode.rawValue, forKey: "themeMode")
        defaults.set(palette.rawValue, forKey: "themePalette")
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
