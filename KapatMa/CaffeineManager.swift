import Foundation
import Combine
import UserNotifications

class CaffeineManager: ObservableObject {
    @Published var isActive = false
    @Published var isInfinite = false
    @Published var totalSeconds: Int = 0
    @Published var remainingSeconds: Int = 0
    @Published var selectedProfile: CaffeineProfile = .deepWork
    @Published var dailyMinutes: Int = 0
    @Published var sessionCount: Int = 0

    private var process: Process?
    private var countdownTimer: Timer?
    private let defaults = UserDefaults.standard

    // MARK: - Profiles

    enum CaffeineProfile: String, CaseIterable, Identifiable {
        case quickMeeting = "Toplantı"
        case deepWork = "Derin Çalışma"
        case longCompute = "Uzun Hesaplama"
        case overnight = "Gece Boyu"
        case infinite = "Sınırsız"

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

        var description: String {
            switch self {
            case .quickMeeting: return "1 Saat"
            case .deepWork: return "4 Saat"
            case .longCompute: return "8 Saat"
            case .overnight: return "12 Saat"
            case .infinite: return "Sınırsız"
            }
        }
    }

    static let presetDurations: [(label: String, seconds: Int)] = [
        ("30 dk", 1800),
        ("1 sa", 3600),
        ("2 sa", 7200),
        ("4 sa", 14400),
        ("8 sa", 28800),
        ("12 sa", 43200),
    ]

    init() {
        loadStats()
        requestNotificationPermission()
    }

    // MARK: - Start / Stop

    func start(seconds: Int?) {
        stop()

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")

        if let secs = seconds {
            proc.arguments = ["-dims", "-t", "\(secs)"]
            totalSeconds = secs
            remainingSeconds = secs
            isInfinite = false
        } else {
            proc.arguments = ["-dims"]
            totalSeconds = 0
            remainingSeconds = 0
            isInfinite = true
        }

        do {
            try proc.run()
            process = proc
            isActive = true
            sessionCount += 1
            saveStats()
            startCountdown()

            if let secs = seconds, secs > 300 {
                scheduleNotification(
                    title: "🔓 Kapat.ma",
                    body: "Ekran uyanık kalma süresi 5 dakika içinde sona erecek.",
                    delay: TimeInterval(secs - 300)
                )
            }
        } catch {
            print("Failed to start caffeinate: \(error)")
        }
    }

    func stop() {
        countdownTimer?.invalidate()
        countdownTimer = nil

        if let proc = process, proc.isRunning {
            proc.terminate()
        }
        process = nil
        isActive = false
        isInfinite = false

        let elapsed = totalSeconds - remainingSeconds
        dailyMinutes += elapsed / 60
        saveStats()

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func startWithProfile(_ profile: CaffeineProfile) {
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
                self.scheduleNotification(
                    title: "🔒 Kapat.ma",
                    body: "Ekran uyanık kalma süresi sona erdi.",
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
