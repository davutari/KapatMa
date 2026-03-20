import Foundation
import Combine
import IOKit.pwr_mgt
import UserNotifications

class AwakeManager: ObservableObject {
    @Published var isActive = false
    @Published var isInfinite = false
    @Published var totalSeconds: Int = 0
    @Published var remainingSeconds: Int = 0
    @Published var selectedProfile: AwakeProfile = .deepWork
    @Published var dailyMinutes: Int = 0
    @Published var sessionCount: Int = 0

    private var assertionID: IOPMAssertionID = IOPMAssertionID(0)
    private var countdownTimer: Timer?
    private let defaults = UserDefaults.standard

    // MARK: - Profiles

    enum AwakeProfile: String, CaseIterable, Identifiable {
        case quickMeeting
        case deepWork
        case longCompute
        case overnight
        case infinite

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .quickMeeting: return "🗣️"
            case .deepWork: return "🧠"
            case .longCompute: return "⚙️"
            case .overnight: return "🌙"
            case .infinite: return "♾️"
            }
        }

        var seconds: Int? {
            switch self {
            case .quickMeeting: return 3600
            case .deepWork: return 14400
            case .longCompute: return 28800
            case .overnight: return 43200
            case .infinite: return nil
            }
        }

        func localizedName(_ L: LocalizationManager) -> String {
            switch self {
            case .quickMeeting: return L.s(.profileMeeting)
            case .deepWork: return L.s(.profileDeepWork)
            case .longCompute: return L.s(.profileLongCompute)
            case .overnight: return L.s(.profileOvernight)
            case .infinite: return L.s(.profileUnlimited)
            }
        }

        func localizedDescription(_ L: LocalizationManager) -> String {
            switch self {
            case .quickMeeting: return L.s(.profileMeetingDesc)
            case .deepWork: return L.s(.profileDeepWorkDesc)
            case .longCompute: return L.s(.profileLongComputeDesc)
            case .overnight: return L.s(.profileOvernightDesc)
            case .infinite: return L.s(.profileUnlimitedDesc)
            }
        }
    }

    static let presetDurations: [(key: L10nKey, seconds: Int)] = [
        (.dur30m, 1800),
        (.dur1h, 3600),
        (.dur2h, 7200),
        (.dur4h, 14400),
        (.dur8h, 28800),
        (.dur12h, 43200),
    ]

    init() {
        loadStats()
        requestNotificationPermission()
    }

    // MARK: - Start / Stop

    func start(seconds: Int?) {
        stop()

        if let secs = seconds {
            totalSeconds = secs
            remainingSeconds = secs
            isInfinite = false
        } else {
            totalSeconds = 0
            remainingSeconds = 0
            isInfinite = true
        }

        // Create power assertion to prevent display sleep and system idle sleep
        let reason = "Kapat.ma keeping screen awake" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        if result == kIOReturnSuccess {
            isActive = true
            sessionCount += 1
            saveStats()
            startCountdown()

            let L = LocalizationManager.shared
            if let secs = seconds, secs > 300 {
                scheduleNotification(
                    title: L.s(.notifWarningTitle),
                    body: L.s(.notifWarningBody),
                    delay: TimeInterval(secs - 300)
                )
            }
        } else {
            print("Failed to create power assertion: \(result)")
        }
    }

    func stop() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        if isActive {
            IOPMAssertionRelease(assertionID)
            assertionID = IOPMAssertionID(0)
        }

        let wasActive = isActive
        isActive = false
        isInfinite = false

        if wasActive {
            let elapsed = totalSeconds - remainingSeconds
            dailyMinutes += elapsed / 60
            saveStats()
        }

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func startWithProfile(_ profile: AwakeProfile) {
        selectedProfile = profile
        if profile == .infinite {
            start(seconds: nil)
        } else if let secs = profile.seconds {
            start(seconds: secs)
        }
    }

    // MARK: - Countdown

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isInfinite { return }

            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.stop()
                let L = LocalizationManager.shared
                self.scheduleNotification(
                    title: L.s(.notifEndTitle),
                    body: L.s(.notifEndBody),
                    delay: 0
                )
            }
        }
    }

    // MARK: - Formatting

    var formattedRemaining: String {
        if isInfinite { return "∞" }
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleNotification(title: String, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Stats Persistence

    private func loadStats() {
        let today = dateKey()
        if defaults.string(forKey: "lastDate") != today {
            defaults.set(today, forKey: "lastDate")
            defaults.set(0, forKey: "dailyMinutes")
            defaults.set(0, forKey: "sessionCount")
        }
        dailyMinutes = defaults.integer(forKey: "dailyMinutes")
        sessionCount = defaults.integer(forKey: "sessionCount")
    }

    private func saveStats() {
        defaults.set(dateKey(), forKey: "lastDate")
        defaults.set(dailyMinutes, forKey: "dailyMinutes")
        defaults.set(sessionCount, forKey: "sessionCount")
    }

    private func dateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
