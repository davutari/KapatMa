import Foundation
import Combine

class QuotesManager: ObservableObject {
    @Published var currentQuoteIndex: Int = 0
    @Published var customQuotes: [Quote] = []

    private let defaults = UserDefaults.standard
    private let customStorageKey = "kapatmaCustomQuotes"
    private var rotationTimer: Timer?
    private var languageCancellable: AnyCancellable?

    struct Quote: Identifiable, Codable, Equatable {
        let id: UUID
        var text: String
        var author: String
        var isCustom: Bool

        init(text: String, author: String = "", isCustom: Bool = false) {
            self.id = UUID()
            self.text = text
            self.author = author
            self.isCustom = isCustom
        }

        enum CodingKeys: String, CodingKey {
            case id, text, author, isCustom
        }
    }

    /// All quotes = localized defaults + user's custom quotes
    var quotes: [Quote] {
        let lang = LocalizationManager.shared.language
        return Self.defaultQuotes(for: lang) + customQuotes
    }

    init() {
        loadCustomQuotes()
        startRotation()

        // Re-publish when language changes so the ticker updates
        languageCancellable = LocalizationManager.shared.$language
            .dropFirst()
            .sink { [weak self] _ in
                self?.currentQuoteIndex = 0
                self?.objectWillChange.send()
            }
    }

    var currentQuote: Quote {
        let all = quotes
        guard !all.isEmpty else {
            return Quote(text: LocalizationManager.shared.s(.defaultQuote))
        }
        return all[currentQuoteIndex % all.count]
    }

    var formattedCurrentQuote: String {
        let q = currentQuote
        if q.author.isEmpty {
            return "\u{201C}\(q.text)\u{201D}"
        }
        return "\u{201C}\(q.text)\u{201D} — \(q.author)"
    }

    func addQuote(text: String, author: String = "") {
        customQuotes.append(Quote(text: text, author: author, isCustom: true))
        saveCustomQuotes()
    }

    func removeQuote(id: UUID) {
        customQuotes.removeAll { $0.id == id }
        let all = quotes
        if currentQuoteIndex >= all.count { currentQuoteIndex = 0 }
        saveCustomQuotes()
    }

    func resetCustomQuotes() {
        customQuotes = []
        currentQuoteIndex = 0
        saveCustomQuotes()
    }

    func nextQuote() {
        let all = quotes
        guard !all.isEmpty else { return }
        currentQuoteIndex = (currentQuoteIndex + 1) % all.count
    }

    func startRotation(interval: TimeInterval = 10.0) {
        rotationTimer?.invalidate()
        rotationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.nextQuote()
        }
    }

    private func loadCustomQuotes() {
        if let data = defaults.data(forKey: customStorageKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            customQuotes = decoded
        }
        // Migrate old quotes: if user had quotes in the old key, extract non-default ones
        if customQuotes.isEmpty, let oldData = defaults.data(forKey: "kapatmaQuotes"),
           let oldQuotes = try? JSONDecoder().decode([Quote].self, from: oldData) {
            let defaultTexts = Set(Self.allDefaultTexts)
            let migrated = oldQuotes.filter { !defaultTexts.contains($0.text) }
                .map { Quote(text: $0.text, author: $0.author, isCustom: true) }
            if !migrated.isEmpty {
                customQuotes = migrated
                saveCustomQuotes()
            }
            defaults.removeObject(forKey: "kapatmaQuotes")
        }
    }

    private func saveCustomQuotes() {
        if let encoded = try? JSONEncoder().encode(customQuotes) {
            defaults.set(encoded, forKey: customStorageKey)
        }
    }

    // MARK: - Localized Default Quotes

    /// All default quote texts across all languages (for migration deduplication)
    private static let allDefaultTexts: [String] = {
        var texts: [String] = []
        for lang in AppLanguage.allCases {
            texts += defaultQuotes(for: lang).map { $0.text }
        }
        return texts
    }()

    static func defaultQuotes(for language: AppLanguage) -> [Quote] {
        switch language {
        case .english:
            return [
                Quote(text: "Success is the sum of small efforts repeated day in and day out.", author: "Robert Collier"),
                Quote(text: "The future depends on what you do today.", author: "Mahatma Gandhi"),
                Quote(text: "Genius is 1% inspiration and 99% perspiration.", author: "Thomas Edison"),
                Quote(text: "The best time is now.", author: ""),
                Quote(text: "Focus. Simplify. Execute.", author: ""),
                Quote(text: "Great things begin with small steps.", author: ""),
                Quote(text: "Writing code is art, debugging is science.", author: ""),
                Quote(text: "Perfect is the enemy of good.", author: "Voltaire"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "Simplicity is the ultimate sophistication.", author: "Leonardo da Vinci"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "The best way to predict the future is to create it.", author: "Peter Drucker"),
            ]

        case .turkish:
            return [
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

        case .spanish:
            return [
                Quote(text: "El éxito es la suma de pequeños esfuerzos repetidos día tras día.", author: "Robert Collier"),
                Quote(text: "El futuro depende de lo que hagas hoy.", author: "Mahatma Gandhi"),
                Quote(text: "El genio es 1% inspiración y 99% transpiración.", author: "Thomas Edison"),
                Quote(text: "El mejor momento es ahora.", author: ""),
                Quote(text: "Enfócate. Simplifica. Ejecuta.", author: ""),
                Quote(text: "Las grandes cosas comienzan con pequeños pasos.", author: ""),
                Quote(text: "Escribir código es arte, depurar es ciencia.", author: ""),
                Quote(text: "Lo perfecto es enemigo de lo bueno.", author: "Voltaire"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "La simplicidad es la máxima sofisticación.", author: "Leonardo da Vinci"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "La mejor forma de predecir el futuro es crearlo.", author: "Peter Drucker"),
            ]

        case .portuguese:
            return [
                Quote(text: "O sucesso é a soma de pequenos esforços repetidos dia após dia.", author: "Robert Collier"),
                Quote(text: "O futuro depende do que você faz hoje.", author: "Mahatma Gandhi"),
                Quote(text: "Gênio é 1% inspiração e 99% transpiração.", author: "Thomas Edison"),
                Quote(text: "O melhor momento é agora.", author: ""),
                Quote(text: "Foque. Simplifique. Execute.", author: ""),
                Quote(text: "Grandes coisas começam com pequenos passos.", author: ""),
                Quote(text: "Escrever código é arte, depurar é ciência.", author: ""),
                Quote(text: "O perfeito é inimigo do bom.", author: "Voltaire"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "Simplicidade é a sofisticação suprema.", author: "Leonardo da Vinci"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "A melhor maneira de prever o futuro é criá-lo.", author: "Peter Drucker"),
            ]

        case .french:
            return [
                Quote(text: "Le succès est la somme de petits efforts répétés jour après jour.", author: "Robert Collier"),
                Quote(text: "L'avenir dépend de ce que vous faites aujourd'hui.", author: "Mahatma Gandhi"),
                Quote(text: "Le génie, c'est 1% d'inspiration et 99% de transpiration.", author: "Thomas Edison"),
                Quote(text: "Le meilleur moment, c'est maintenant.", author: ""),
                Quote(text: "Concentrez-vous. Simplifiez. Exécutez.", author: ""),
                Quote(text: "Les grandes choses commencent par de petits pas.", author: ""),
                Quote(text: "Écrire du code est un art, déboguer est une science.", author: ""),
                Quote(text: "Le mieux est l'ennemi du bien.", author: "Voltaire"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "La simplicité est la sophistication suprême.", author: "Leonardo da Vinci"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "La meilleure façon de prédire l'avenir est de le créer.", author: "Peter Drucker"),
            ]

        case .german:
            return [
                Quote(text: "Erfolg ist die Summe kleiner Anstrengungen, die Tag für Tag wiederholt werden.", author: "Robert Collier"),
                Quote(text: "Die Zukunft hängt davon ab, was du heute tust.", author: "Mahatma Gandhi"),
                Quote(text: "Genie ist 1% Inspiration und 99% Transpiration.", author: "Thomas Edison"),
                Quote(text: "Die beste Zeit ist jetzt.", author: ""),
                Quote(text: "Fokussieren. Vereinfachen. Umsetzen.", author: ""),
                Quote(text: "Große Dinge beginnen mit kleinen Schritten.", author: ""),
                Quote(text: "Code schreiben ist Kunst, Debuggen ist Wissenschaft.", author: ""),
                Quote(text: "Das Bessere ist der Feind des Guten.", author: "Voltaire"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "Einfachheit ist die höchste Stufe der Vollendung.", author: "Leonardo da Vinci"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "Der beste Weg, die Zukunft vorherzusagen, ist sie zu gestalten.", author: "Peter Drucker"),
            ]

        case .japanese:
            return [
                Quote(text: "成功とは、毎日繰り返される小さな努力の積み重ねである。", author: "ロバート・コリアー"),
                Quote(text: "未来は、今日あなたが何をするかにかかっている。", author: "マハトマ・ガンジー"),
                Quote(text: "天才とは1%のひらめきと99%の努力である。", author: "トーマス・エジソン"),
                Quote(text: "最高の時は今。", author: ""),
                Quote(text: "集中する。簡素にする。実行する。", author: ""),
                Quote(text: "偉大なことは、小さな一歩から始まる。", author: ""),
                Quote(text: "コードを書くのは芸術、デバッグは科学。", author: ""),
                Quote(text: "完璧は善の敵である。", author: "ヴォルテール"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "シンプルさは究極の洗練である。", author: "レオナルド・ダ・ヴィンチ"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "未来を予測する最善の方法は、それを創ることだ。", author: "ピーター・ドラッカー"),
            ]

        case .korean:
            return [
                Quote(text: "성공은 매일 반복되는 작은 노력의 합이다.", author: "로버트 콜리어"),
                Quote(text: "미래는 오늘 당신이 무엇을 하느냐에 달려 있다.", author: "마하트마 간디"),
                Quote(text: "천재는 1%의 영감과 99%의 노력이다.", author: "토머스 에디슨"),
                Quote(text: "가장 좋은 때는 바로 지금이다.", author: ""),
                Quote(text: "집중하라. 단순하게. 실행하라.", author: ""),
                Quote(text: "위대한 일은 작은 걸음에서 시작된다.", author: ""),
                Quote(text: "코드를 쓰는 것은 예술, 디버깅은 과학이다.", author: ""),
                Quote(text: "완벽은 좋음의 적이다.", author: "볼테르"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "단순함이야말로 궁극의 정교함이다.", author: "레오나르도 다 빈치"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "미래를 예측하는 가장 좋은 방법은 미래를 만드는 것이다.", author: "피터 드러커"),
            ]

        case .chinese:
            return [
                Quote(text: "成功是每天重复的小小努力的总和。", author: "罗伯特·科利尔"),
                Quote(text: "未来取决于你今天做什么。", author: "圣雄甘地"),
                Quote(text: "天才是1%的灵感加99%的汗水。", author: "托马斯·爱迪生"),
                Quote(text: "最好的时间就是现在。", author: ""),
                Quote(text: "专注。简化。执行。", author: ""),
                Quote(text: "伟大的事情从小步开始。", author: ""),
                Quote(text: "写代码是艺术，调试是科学。", author: ""),
                Quote(text: "完美是好的敌人。", author: "伏尔泰"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "简单是终极的精致。", author: "列奥纳多·达·芬奇"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "预测未来的最好方法就是创造未来。", author: "彼得·德鲁克"),
            ]

        case .arabic:
            return [
                Quote(text: "النجاح هو مجموع الجهود الصغيرة المتكررة يومًا بعد يوم.", author: "روبرت كولير"),
                Quote(text: "المستقبل يعتمد على ما تفعله اليوم.", author: "المهاتما غاندي"),
                Quote(text: "العبقرية هي 1% إلهام و99% عرق.", author: "توماس إديسون"),
                Quote(text: "أفضل وقت هو الآن.", author: ""),
                Quote(text: "ركّز. بسّط. نفّذ.", author: ""),
                Quote(text: "الأشياء العظيمة تبدأ بخطوات صغيرة.", author: ""),
                Quote(text: "كتابة الكود فن، وتصحيح الأخطاء علم.", author: ""),
                Quote(text: "الكمال عدو الجيد.", author: "فولتير"),
                Quote(text: "Talk is cheap. Show me the code.", author: "Linus Torvalds"),
                Quote(text: "البساطة هي قمة التطور.", author: "ليوناردو دا فينشي"),
                Quote(text: "Stay hungry, stay foolish.", author: "Steve Jobs"),
                Quote(text: "أفضل طريقة للتنبؤ بالمستقبل هي صناعته.", author: "بيتر دراكر"),
            ]
        }
    }
}
