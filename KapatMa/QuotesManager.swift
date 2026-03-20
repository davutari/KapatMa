import Foundation

class QuotesManager: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var currentQuoteIndex: Int = 0

    private let defaults = UserDefaults.standard
    private let storageKey = "kapatmaQuotes"
    private var rotationTimer: Timer?

    struct Quote: Identifiable, Codable, Equatable {
        let id: UUID
        var text: String
        var author: String

        init(text: String, author: String = "") {
            self.id = UUID()
            self.text = text
            self.author = author
        }
    }

    static let defaultQuotes: [Quote] = [
        Quote(text: "Başarı, her gün tekrarlanan küçük çabaların toplamıdır.", author: "Robert Collier"),
        Quote(text: "Gelecek, bugün ne yaptığına bağlıdır.", author: "Mahatma Gandhi"),
        Quote(text: "Dahi, %1 ilham ve %99 terdir.", author: "Thomas Edison"),
        Quote(text: "En iyi zaman şimdi.", author: ""),
        Quote(text: "Odaklan. Basitleştir. Yap.", author: ""),
        Quote(text: "Büyük işler, küçük adımlarla başlar.", author: ""),
        Quote(text: "Kod yazmak sanat, debug etmek bilimdir.", author: ""),
        Quote(text: "Mükemmel, iyinin düşmanıdır.", author: "Voltaire"),
        Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
        Quote(text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci"),
        Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
        Quote(text: "Bir şeyleri değiştirmenin en iyi yolu, onları yapmaya başlamaktır.", author: ""),
    ]

    init() {
        loadQuotes()
        startRotation()
    }

    var currentQuote: Quote {
        guard !quotes.isEmpty else {
            return Quote(text: LocalizationManager.shared.s(.defaultQuote))
        }
        return quotes[currentQuoteIndex % quotes.count]
    }

    var formattedCurrentQuote: String {
        let q = currentQuote
        if q.author.isEmpty {
            return "\u{201C}\(q.text)\u{201D}"
        }
        return "\u{201C}\(q.text)\u{201D} — \(q.author)"
    }

    func addQuote(text: String, author: String = "") {
        quotes.append(Quote(text: text, author: author))
        saveQuotes()
    }

    func removeQuote(id: UUID) {
        quotes.removeAll { $0.id == id }
        if currentQuoteIndex >= quotes.count { currentQuoteIndex = 0 }
        saveQuotes()
    }

    func nextQuote() {
        guard !quotes.isEmpty else { return }
        currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
    }

    func startRotation(interval: TimeInterval = 10.0) {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.nextQuote()
        }
    }

    private func loadQuotes() {
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            quotes = decoded
        } else {
            quotes = QuotesManager.defaultQuotes
            saveQuotes()
        }
    }

    private func saveQuotes() {
        if let encoded = try? JSONEncoder().encode(quotes) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
}
