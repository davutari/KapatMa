import SwiftUI

struct MainPopoverView: View {
    @ObservedObject var awakeManager: AwakeManager
    @ObservedObject var quotesManager: QuotesManager
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var brightnessManager: BrightnessManager
    @ObservedObject var localizationManager: LocalizationManager
    @State private var showQuoteEditor = false
    @State private var showSettings = false
    @State private var customHours: Double = 1
    @State private var showCustomPicker = false

    private var t: AppTheme { themeManager.theme }
    private var L: LocalizationManager { localizationManager }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            divider

            if awakeManager.isActive {
                activeSessionView
            } else {
                inactiveView
            }

            if !brightnessManager.displays.isEmpty {
                divider
                brightnessSection
            }

            divider
            quotesTicker
            divider
            footerStats
        }
        .frame(width: 370)
        .background(t.popoverBg)
    }

    private var divider: some View {
        Rectangle().fill(t.border).frame(height: 1)
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 10) {
            // App icon - lock metaphor
            Image(systemName: awakeManager.isActive ? "lock.open.fill" : "lock.fill")
                .font(.title2)
                .foregroundColor(t.accent)

            VStack(alignment: .leading, spacing: 1) {
                Text("Kapat.ma")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(t.textPrimary)
                Text(L.s(.appTagline))
                    .font(.system(size: 9))
                    .foregroundColor(t.textTertiary)
            }

            Spacer()

            if awakeManager.isActive {
                Text(L.s(.active))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(t.activeText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(t.activeBg)
                    )
            }

            // Settings
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 13))
                    .foregroundColor(t.textTertiary)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showSettings) {
                SettingsView(themeManager: themeManager, quotesManager: quotesManager, localizationManager: localizationManager)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Active Session

    private var activeSessionView: some View {
        VStack(spacing: 16) {
            ZStack {
                // Track
                Circle()
                    .stroke(t.ringTrack, lineWidth: 8)
                    .frame(width: 170, height: 170)

                // Progress arc
                if !awakeManager.isInfinite {
                    Circle()
                        .trim(from: 0, to: awakeManager.progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [t.accent, t.accentSecondary, t.accent]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: awakeManager.progress)
                        .shadow(color: themeManager.theme.palette.glow, radius: 8)
                }

                // Center
                VStack(spacing: 4) {
                    Text(awakeManager.isInfinite ? "♾️" : awakeManager.formattedRemaining)
                        .font(.system(size: 34, weight: .bold, design: .monospaced))
                        .foregroundColor(t.textPrimary)

                    Text(awakeManager.selectedProfile.localizedName(L))
                        .font(.system(size: 11))
                        .foregroundColor(t.textSecondary)

                    Circle()
                        .fill(t.activeDot)
                        .frame(width: 8, height: 8)
                        .shadow(color: t.activeDot.opacity(0.6), radius: 4)
                }
            }
            .padding(.top, 10)

            // Stop Button
            Button(action: { awakeManager.stop() }) {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 13))
                    Text(L.s(.stopButton))
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(t.stopBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(t.stopBorder, lineWidth: 1)
                        )
                )
                .foregroundColor(t.stopText)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 22)
            .padding(.bottom, 10)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Inactive View

    private var inactiveView: some View {
        VStack(spacing: 14) {
            Text(L.s(.keepScreenAwake))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(t.textSecondary)
                .padding(.top, 10)

            profileButtons
            quickDurationButtons

            if showCustomPicker {
                customDurationPicker
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 14)
    }

    private var profileButtons: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(AwakeManager.AwakeProfile.allCases, id: \.self) { profile in
                Button(action: { awakeManager.startWithProfile(profile) }) {
                    VStack(spacing: 5) {
                        Text(profile.icon)
                            .font(.title2)
                        Text(profile.localizedName(L))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(t.textPrimary)
                            .lineLimit(1)
                        Text(profile.localizedDescription(L))
                            .font(.system(size: 9))
                            .foregroundColor(t.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(t.cardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(t.border, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quickDurationButtons: some View {
        VStack(spacing: 7) {
            HStack {
                Text(L.s(.quickStart))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(t.textSecondary)
                Spacer()
                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { showCustomPicker.toggle() } }) {
                    HStack(spacing: 3) {
                        Image(systemName: "slider.horizontal.3")
                        Text(L.s(.custom))
                    }
                    .font(.system(size: 11))
                    .foregroundColor(t.accent)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 5) {
                ForEach(AwakeManager.presetDurations, id: \.seconds) { preset in
                    Button(action: { awakeManager.start(seconds: preset.seconds) }) {
                        Text(L.s(preset.key))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(t.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(t.accentBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(t.accentBorder, lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var customDurationPicker: some View {
        VStack(spacing: 10) {
            Text("\(L.s(.customDuration)): \(formattedCustomDuration)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(t.textSecondary)

            Slider(value: $customHours, in: 0.5...24, step: 0.5)
                .accentColor(t.accent)

            Button(action: {
                awakeManager.start(seconds: Int(customHours * 3600))
                showCustomPicker = false
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 11))
                    Text("\(formattedCustomDuration) \(L.s(.startButton))")
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(t.accentBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(t.accentBorder, lineWidth: 1)
                        )
                )
                .foregroundColor(t.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(t.elevatedBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(t.border, lineWidth: 1)
                )
        )
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private var formattedCustomDuration: String {
        let h = Int(customHours)
        let m = Int((customHours - Double(h)) * 60)
        if m == 0 { return "\(h) \(L.s(.hours))" }
        return "\(h) \(L.s(.hours)) \(m) \(L.s(.minutes))"
    }

    // MARK: - Brightness Control

    private var brightnessSection: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(t.accent)
                    .font(.system(size: 12))
                Text(L.s(.screenBrightness))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(t.textSecondary)
                Spacer()
                Button(action: { brightnessManager.refreshDisplays() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                        .foregroundColor(t.textTertiary)
                }
                .buttonStyle(.plain)
            }

            ForEach(brightnessManager.displays) { display in
                VStack(spacing: 4) {
                    HStack {
                        Image(systemName: "display")
                            .font(.system(size: 10))
                            .foregroundColor(t.textTertiary)
                        Text(display.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(t.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("%\(display.brightness)")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(t.accent)
                            .frame(width: 38, alignment: .trailing)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: "sun.min")
                            .font(.system(size: 9))
                            .foregroundColor(t.textTertiary)

                        Slider(
                            value: Binding(
                                get: { Double(display.brightness) },
                                set: { brightnessManager.setBrightness(Int($0), for: display.id) }
                            ),
                            in: 16...100,
                            step: 1
                        )
                        .accentColor(t.accent)

                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 9))
                            .foregroundColor(t.textTertiary)
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(t.cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(t.border, lineWidth: 1)
                        )
                )
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }

    // MARK: - Quotes Ticker

    private var quotesTicker: some View {
        Text(quotesManager.formattedCurrentQuote)
            .font(.system(size: 11, design: .serif))
            .italic()
            .foregroundColor(t.textSecondary)
            .lineLimit(2)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .id(quotesManager.currentQuoteIndex)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.5), value: quotesManager.currentQuoteIndex)
            .onTapGesture {
                withAnimation { quotesManager.nextQuote() }
            }
    }

    // MARK: - Footer

    private var footerStats: some View {
        HStack {
            Label("\(awakeManager.sessionCount) \(L.s(.sessionCount))", systemImage: "bolt.fill")
                .font(.system(size: 10))
                .foregroundColor(t.textTertiary)

            Spacer()

            Label("\(L.s(.todayMinutes)) \(awakeManager.dailyMinutes) \(L.s(.minutes))", systemImage: "clock.fill")
                .font(.system(size: 10))
                .foregroundColor(t.textTertiary)

            Spacer()

            Text("⌘⇧K")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(t.textTertiary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(t.cardBg)
                )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject var quotesManager: QuotesManager
    @ObservedObject var localizationManager: LocalizationManager
    @State private var showQuoteEditor = false

    private var t: AppTheme { themeManager.theme }
    private var L: LocalizationManager { localizationManager }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            HStack {
                Image(systemName: "gearshape.fill")
                    .foregroundColor(t.accent)
                Text(L.s(.settings))
                    .font(.headline)
                    .foregroundColor(t.textPrimary)
            }

            // Theme Mode
            VStack(alignment: .leading, spacing: 8) {
                Text(L.s(.themeMode))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(t.textSecondary)

                HStack(spacing: 6) {
                    ForEach(ThemeMode.allCases) { mode in
                        Button(action: { themeManager.mode = mode }) {
                            HStack(spacing: 4) {
                                Text(mode.icon)
                                    .font(.system(size: 12))
                                Text(mode.localizedName(L))
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.mode == mode ? t.accentBg : t.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(themeManager.mode == mode ? t.accent.opacity(0.4) : t.border, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(themeManager.mode == mode ? t.accent : t.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Color Palette
            VStack(alignment: .leading, spacing: 8) {
                Text(L.s(.colorPalette))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(t.textSecondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(ColorPalette.allCases) { palette in
                        Button(action: { themeManager.palette = palette }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(palette.accent)
                                        .frame(width: 28, height: 28)

                                    if themeManager.palette == palette {
                                        Circle()
                                            .stroke(t.isDark ? Color.white : Color.black.opacity(0.3), lineWidth: 2.5)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 0)
                                    }
                                }
                                .shadow(color: palette.accent.opacity(themeManager.palette == palette ? 0.5 : 0), radius: 6)

                                Text(palette.localizedName(L))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(themeManager.palette == palette ? t.textPrimary : t.textTertiary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.palette == palette ? t.accentBg : Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(themeManager.palette == palette ? palette.accent.opacity(0.4) : Color.clear, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            // Language
            VStack(alignment: .leading, spacing: 8) {
                Text(L.s(.language))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(t.textSecondary)

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 6) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button(action: { localizationManager.language = lang }) {
                            HStack(spacing: 4) {
                                Text(lang.flag)
                                    .font(.system(size: 12))
                                Text(lang.displayName)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(localizationManager.language == lang ? t.accentBg : t.cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(localizationManager.language == lang ? t.accent.opacity(0.4) : t.border, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(localizationManager.language == lang ? t.accent : t.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Divider()

            // Quote Editor Link
            Button(action: { showQuoteEditor.toggle() }) {
                HStack {
                    Image(systemName: "quote.bubble.fill")
                        .foregroundColor(t.accent)
                    Text(L.s(.editQuotes))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(t.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(t.textTertiary)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(t.cardBg)
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showQuoteEditor) {
                QuoteEditorView(quotesManager: quotesManager, theme: t, localizationManager: localizationManager)
            }

            Divider()

            // Quit
            Button(action: {
                NSApp.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                        .foregroundColor(.red)
                    Text(L.s(.quitApp))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .frame(width: 300)
        .background(t.popoverBg)
    }
}

// MARK: - Quote Editor

struct QuoteEditorView: View {
    @ObservedObject var quotesManager: QuotesManager
    let theme: AppTheme
    @ObservedObject var localizationManager: LocalizationManager
    @State private var newText = ""
    @State private var newAuthor = ""
    private var L: LocalizationManager { localizationManager }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L.s(.motivationalQuotes))
                .font(.headline)
                .foregroundColor(theme.textPrimary)

            // Add new
            VStack(spacing: 6) {
                TextField(L.s(.writeQuote), text: $newText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 12))

                HStack {
                    TextField(L.s(.authorOptional), text: $newAuthor)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 12))

                    Button(action: {
                        guard !newText.isEmpty else { return }
                        quotesManager.addQuote(text: newText, author: newAuthor)
                        newText = ""
                        newAuthor = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(theme.accent)
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                    .disabled(newText.isEmpty)
                }
            }

            Divider()

            ScrollView {
                VStack(spacing: 4) {
                    if !quotesManager.customQuotes.isEmpty {
                        ForEach(quotesManager.customQuotes) { quote in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(quote.text)
                                        .font(.system(size: 11))
                                        .foregroundColor(theme.textPrimary)
                                        .lineLimit(2)
                                    if !quote.author.isEmpty {
                                        Text("— \(quote.author)")
                                            .font(.system(size: 10))
                                            .foregroundColor(theme.textTertiary)
                                    }
                                }
                                Spacer()
                                Button(action: { quotesManager.removeQuote(id: quote.id) }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 10))
                                        .foregroundColor(.red.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(theme.cardBg)
                            )
                        }
                    } else {
                        Text(L.s(.defaultQuote))
                            .font(.system(size: 11))
                            .foregroundColor(theme.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
            }
            .frame(maxHeight: 200)

            if !quotesManager.customQuotes.isEmpty {
                HStack {
                    Spacer()
                    Button(L.s(.resetDefaults)) {
                        quotesManager.resetCustomQuotes()
                    }
                    .font(.system(size: 10))
                    .foregroundColor(theme.textTertiary)
                }
            }
        }
        .padding(16)
        .frame(width: 320, height: 400)
        .background(theme.popoverBg)
    }
}
