import Foundation

// MARK: - Supported Languages

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case turkish = "tr"
    case spanish = "es"
    case portuguese = "pt"
    case french = "fr"
    case german = "de"
    case japanese = "ja"
    case korean = "ko"
    case chinese = "zh"
    case arabic = "ar"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .spanish: return "Español"
        case .portuguese: return "Português"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .chinese: return "中文"
        case .arabic: return "العربية"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .turkish: return "🇹🇷"
        case .spanish: return "🇪🇸"
        case .portuguese: return "🇧🇷"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .japanese: return "🇯🇵"
        case .korean: return "🇰🇷"
        case .chinese: return "🇨🇳"
        case .arabic: return "🇸🇦"
        }
    }
}

// MARK: - Localization Keys

enum L10nKey: String {
    // App
    case appTagline
    case keepScreenAwake

    // Status
    case active
    case sessionCount
    case todayMinutes

    // Profiles
    case profileMeeting
    case profileDeepWork
    case profileLongCompute
    case profileOvernight
    case profileUnlimited
    case profileMeetingDesc
    case profileDeepWorkDesc
    case profileLongComputeDesc
    case profileOvernightDesc
    case profileUnlimitedDesc

    // Durations
    case quickStart
    case custom
    case customDuration
    case startButton
    case stopButton
    case hours
    case minutes

    // Brightness
    case screenBrightness
    case externalMonitor

    // Settings
    case settings
    case themeMode
    case colorPalette
    case language
    case editQuotes
    case quitApp

    // Theme modes
    case themeSystem
    case themeLight
    case themeDark

    // Color palettes
    case paletteEspresso
    case paletteOcean
    case paletteSunset
    case paletteForest
    case paletteLavender
    case paletteCherry

    // Quotes
    case motivationalQuotes
    case writeQuote
    case authorOptional
    case resetDefaults
    case defaultQuote

    // Notifications
    case notifWarningTitle
    case notifWarningBody
    case notifEndTitle
    case notifEndBody

    // Duration labels
    case dur30m
    case dur1h
    case dur2h
    case dur4h
    case dur8h
    case dur12h
    case hour1
    case hour4
    case hour8
    case hour12
    case unlimited
}

// MARK: - Localization Manager

class LocalizationManager: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        }
    }

    static let shared = LocalizationManager()

    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        self.language = AppLanguage(rawValue: saved) ?? .english
    }

    func s(_ key: L10nKey) -> String {
        return Self.strings[language]?[key] ?? Self.strings[.english]![key]!
    }

    // MARK: - All Translations

    private static let strings: [AppLanguage: [L10nKey: String]] = [

        // MARK: English
        .english: [
            .appTagline: "Don't let your screen sleep!",
            .keepScreenAwake: "Keep Screen Awake",
            .active: "ACTIVE",
            .sessionCount: "sessions",
            .todayMinutes: "Today",
            .profileMeeting: "Meeting",
            .profileDeepWork: "Deep Work",
            .profileLongCompute: "Long Compute",
            .profileOvernight: "Overnight",
            .profileUnlimited: "Unlimited",
            .profileMeetingDesc: "1 Hour",
            .profileDeepWorkDesc: "4 Hours",
            .profileLongComputeDesc: "8 Hours",
            .profileOvernightDesc: "12 Hours",
            .profileUnlimitedDesc: "Unlimited",
            .quickStart: "Quick Start",
            .custom: "Custom",
            .customDuration: "Custom Duration",
            .startButton: "Start",
            .stopButton: "Stop",
            .hours: "hours",
            .minutes: "min",
            .screenBrightness: "Screen Brightness",
            .externalMonitor: "External Monitor",
            .settings: "Settings",
            .themeMode: "Theme Mode",
            .colorPalette: "Color Palette",
            .language: "Language",
            .editQuotes: "Edit Quotes",
            .quitApp: "Quit Kapat.ma",
            .themeSystem: "System",
            .themeLight: "Light",
            .themeDark: "Dark",
            .paletteEspresso: "Espresso",
            .paletteOcean: "Ocean",
            .paletteSunset: "Sunset",
            .paletteForest: "Forest",
            .paletteLavender: "Lavender",
            .paletteCherry: "Cherry",
            .motivationalQuotes: "Motivational Quotes",
            .writeQuote: "Write a quote...",
            .authorOptional: "Author (optional)",
            .resetDefaults: "Reset to Defaults",
            .defaultQuote: "Keep working to achieve great things!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "Screen awake time will end in 5 minutes.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "Screen awake time has ended.",
            .dur30m: "30m",
            .dur1h: "1h",
            .dur2h: "2h",
            .dur4h: "4h",
            .dur8h: "8h",
            .dur12h: "12h",
            .hour1: "1 Hour",
            .hour4: "4 Hours",
            .hour8: "8 Hours",
            .hour12: "12 Hours",
            .unlimited: "Unlimited",
        ],

        // MARK: Turkish
        .turkish: [
            .appTagline: "Ekranını kapatma!",
            .keepScreenAwake: "Ekranı Uyanık Tut",
            .active: "AKTİF",
            .sessionCount: "oturum",
            .todayMinutes: "Bugün",
            .profileMeeting: "Toplantı",
            .profileDeepWork: "Derin Çalışma",
            .profileLongCompute: "Uzun Hesaplama",
            .profileOvernight: "Gece Boyu",
            .profileUnlimited: "Sınırsız",
            .profileMeetingDesc: "1 Saat",
            .profileDeepWorkDesc: "4 Saat",
            .profileLongComputeDesc: "8 Saat",
            .profileOvernightDesc: "12 Saat",
            .profileUnlimitedDesc: "Sınırsız",
            .quickStart: "Hızlı Başlat",
            .custom: "Özel",
            .customDuration: "Özel Süre",
            .startButton: "Başlat",
            .stopButton: "Durdur",
            .hours: "saat",
            .minutes: "dk",
            .screenBrightness: "Ekran Parlaklığı",
            .externalMonitor: "Harici Monitör",
            .settings: "Ayarlar",
            .themeMode: "Tema Modu",
            .colorPalette: "Renk Paleti",
            .language: "Dil",
            .editQuotes: "Sözleri Düzenle",
            .quitApp: "Kapat.ma'yı Kapat",
            .themeSystem: "Sistem",
            .themeLight: "Aydınlık",
            .themeDark: "Karanlık",
            .paletteEspresso: "Espresso",
            .paletteOcean: "Okyanus",
            .paletteSunset: "Gün Batımı",
            .paletteForest: "Orman",
            .paletteLavender: "Lavanta",
            .paletteCherry: "Vişne",
            .motivationalQuotes: "Motivasyon Sözleri",
            .writeQuote: "Söz yazın...",
            .authorOptional: "Yazar (opsiyonel)",
            .resetDefaults: "Varsayılanlara Sıfırla",
            .defaultQuote: "Harika işler başarmak için çalışmaya devam et!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "Ekran uyanık kalma süresi 5 dakika içinde sona erecek.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "Ekran uyanık kalma süresi sona erdi.",
            .dur30m: "30 dk",
            .dur1h: "1 sa",
            .dur2h: "2 sa",
            .dur4h: "4 sa",
            .dur8h: "8 sa",
            .dur12h: "12 sa",
            .hour1: "1 Saat",
            .hour4: "4 Saat",
            .hour8: "8 Saat",
            .hour12: "12 Saat",
            .unlimited: "Sınırsız",
        ],

        // MARK: Spanish
        .spanish: [
            .appTagline: "¡No dejes que tu pantalla se apague!",
            .keepScreenAwake: "Mantener Pantalla Activa",
            .active: "ACTIVO",
            .sessionCount: "sesiones",
            .todayMinutes: "Hoy",
            .profileMeeting: "Reunión",
            .profileDeepWork: "Trabajo Profundo",
            .profileLongCompute: "Cálculo Largo",
            .profileOvernight: "Toda la Noche",
            .profileUnlimited: "Ilimitado",
            .profileMeetingDesc: "1 Hora",
            .profileDeepWorkDesc: "4 Horas",
            .profileLongComputeDesc: "8 Horas",
            .profileOvernightDesc: "12 Horas",
            .profileUnlimitedDesc: "Ilimitado",
            .quickStart: "Inicio Rápido",
            .custom: "Personalizar",
            .customDuration: "Duración Personalizada",
            .startButton: "Iniciar",
            .stopButton: "Detener",
            .hours: "horas",
            .minutes: "min",
            .screenBrightness: "Brillo de Pantalla",
            .externalMonitor: "Monitor Externo",
            .settings: "Ajustes",
            .themeMode: "Modo de Tema",
            .colorPalette: "Paleta de Colores",
            .language: "Idioma",
            .editQuotes: "Editar Citas",
            .quitApp: "Salir de Kapat.ma",
            .themeSystem: "Sistema",
            .themeLight: "Claro",
            .themeDark: "Oscuro",
            .paletteEspresso: "Espresso",
            .paletteOcean: "Océano",
            .paletteSunset: "Atardecer",
            .paletteForest: "Bosque",
            .paletteLavender: "Lavanda",
            .paletteCherry: "Cereza",
            .motivationalQuotes: "Citas Motivacionales",
            .writeQuote: "Escribe una cita...",
            .authorOptional: "Autor (opcional)",
            .resetDefaults: "Restablecer",
            .defaultQuote: "¡Sigue trabajando para lograr grandes cosas!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "El tiempo de pantalla activa terminará en 5 minutos.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "El tiempo de pantalla activa ha terminado.",
            .dur30m: "30m",
            .dur1h: "1h",
            .dur2h: "2h",
            .dur4h: "4h",
            .dur8h: "8h",
            .dur12h: "12h",
            .hour1: "1 Hora",
            .hour4: "4 Horas",
            .hour8: "8 Horas",
            .hour12: "12 Horas",
            .unlimited: "Ilimitado",
        ],

        // MARK: Portuguese
        .portuguese: [
            .appTagline: "Não deixe sua tela dormir!",
            .keepScreenAwake: "Manter Tela Ativa",
            .active: "ATIVO",
            .sessionCount: "sessões",
            .todayMinutes: "Hoje",
            .profileMeeting: "Reunião",
            .profileDeepWork: "Trabalho Focado",
            .profileLongCompute: "Cálculo Longo",
            .profileOvernight: "Noite Toda",
            .profileUnlimited: "Ilimitado",
            .profileMeetingDesc: "1 Hora",
            .profileDeepWorkDesc: "4 Horas",
            .profileLongComputeDesc: "8 Horas",
            .profileOvernightDesc: "12 Horas",
            .profileUnlimitedDesc: "Ilimitado",
            .quickStart: "Início Rápido",
            .custom: "Personalizar",
            .customDuration: "Duração Personalizada",
            .startButton: "Iniciar",
            .stopButton: "Parar",
            .hours: "horas",
            .minutes: "min",
            .screenBrightness: "Brilho da Tela",
            .externalMonitor: "Monitor Externo",
            .settings: "Configurações",
            .themeMode: "Modo do Tema",
            .colorPalette: "Paleta de Cores",
            .language: "Idioma",
            .editQuotes: "Editar Citações",
            .quitApp: "Sair do Kapat.ma",
            .themeSystem: "Sistema",
            .themeLight: "Claro",
            .themeDark: "Escuro",
            .paletteEspresso: "Espresso",
            .paletteOcean: "Oceano",
            .paletteSunset: "Pôr do Sol",
            .paletteForest: "Floresta",
            .paletteLavender: "Lavanda",
            .paletteCherry: "Cereja",
            .motivationalQuotes: "Citações Motivacionais",
            .writeQuote: "Escreva uma citação...",
            .authorOptional: "Autor (opcional)",
            .resetDefaults: "Redefinir Padrões",
            .defaultQuote: "Continue trabalhando para alcançar grandes coisas!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "O tempo de tela ativa terminará em 5 minutos.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "O tempo de tela ativa terminou.",
            .dur30m: "30m",
            .dur1h: "1h",
            .dur2h: "2h",
            .dur4h: "4h",
            .dur8h: "8h",
            .dur12h: "12h",
            .hour1: "1 Hora",
            .hour4: "4 Horas",
            .hour8: "8 Horas",
            .hour12: "12 Horas",
            .unlimited: "Ilimitado",
        ],

        // MARK: French
        .french: [
            .appTagline: "Ne laissez pas votre écran s'éteindre !",
            .keepScreenAwake: "Garder l'Écran Éveillé",
            .active: "ACTIF",
            .sessionCount: "sessions",
            .todayMinutes: "Aujourd'hui",
            .profileMeeting: "Réunion",
            .profileDeepWork: "Travail Profond",
            .profileLongCompute: "Calcul Long",
            .profileOvernight: "Toute la Nuit",
            .profileUnlimited: "Illimité",
            .profileMeetingDesc: "1 Heure",
            .profileDeepWorkDesc: "4 Heures",
            .profileLongComputeDesc: "8 Heures",
            .profileOvernightDesc: "12 Heures",
            .profileUnlimitedDesc: "Illimité",
            .quickStart: "Démarrage Rapide",
            .custom: "Personnaliser",
            .customDuration: "Durée Personnalisée",
            .startButton: "Démarrer",
            .stopButton: "Arrêter",
            .hours: "heures",
            .minutes: "min",
            .screenBrightness: "Luminosité de l'Écran",
            .externalMonitor: "Moniteur Externe",
            .settings: "Paramètres",
            .themeMode: "Mode du Thème",
            .colorPalette: "Palette de Couleurs",
            .language: "Langue",
            .editQuotes: "Modifier les Citations",
            .quitApp: "Quitter Kapat.ma",
            .themeSystem: "Système",
            .themeLight: "Clair",
            .themeDark: "Sombre",
            .paletteEspresso: "Espresso",
            .paletteOcean: "Océan",
            .paletteSunset: "Coucher de Soleil",
            .paletteForest: "Forêt",
            .paletteLavender: "Lavande",
            .paletteCherry: "Cerise",
            .motivationalQuotes: "Citations Motivantes",
            .writeQuote: "Écrire une citation...",
            .authorOptional: "Auteur (optionnel)",
            .resetDefaults: "Réinitialiser",
            .defaultQuote: "Continuez à travailler pour accomplir de grandes choses !",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "Le temps d'écran actif se terminera dans 5 minutes.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "Le temps d'écran actif est terminé.",
            .dur30m: "30m",
            .dur1h: "1h",
            .dur2h: "2h",
            .dur4h: "4h",
            .dur8h: "8h",
            .dur12h: "12h",
            .hour1: "1 Heure",
            .hour4: "4 Heures",
            .hour8: "8 Heures",
            .hour12: "12 Heures",
            .unlimited: "Illimité",
        ],

        // MARK: German
        .german: [
            .appTagline: "Lass deinen Bildschirm nicht einschlafen!",
            .keepScreenAwake: "Bildschirm Wach Halten",
            .active: "AKTIV",
            .sessionCount: "Sitzungen",
            .todayMinutes: "Heute",
            .profileMeeting: "Meeting",
            .profileDeepWork: "Deep Work",
            .profileLongCompute: "Lange Berechnung",
            .profileOvernight: "Über Nacht",
            .profileUnlimited: "Unbegrenzt",
            .profileMeetingDesc: "1 Stunde",
            .profileDeepWorkDesc: "4 Stunden",
            .profileLongComputeDesc: "8 Stunden",
            .profileOvernightDesc: "12 Stunden",
            .profileUnlimitedDesc: "Unbegrenzt",
            .quickStart: "Schnellstart",
            .custom: "Benutzerdefiniert",
            .customDuration: "Benutzerdefinierte Dauer",
            .startButton: "Starten",
            .stopButton: "Stoppen",
            .hours: "Stunden",
            .minutes: "Min",
            .screenBrightness: "Bildschirmhelligkeit",
            .externalMonitor: "Externer Monitor",
            .settings: "Einstellungen",
            .themeMode: "Themenmodus",
            .colorPalette: "Farbpalette",
            .language: "Sprache",
            .editQuotes: "Zitate Bearbeiten",
            .quitApp: "Kapat.ma Beenden",
            .themeSystem: "System",
            .themeLight: "Hell",
            .themeDark: "Dunkel",
            .paletteEspresso: "Espresso",
            .paletteOcean: "Ozean",
            .paletteSunset: "Sonnenuntergang",
            .paletteForest: "Wald",
            .paletteLavender: "Lavendel",
            .paletteCherry: "Kirsche",
            .motivationalQuotes: "Motivationszitate",
            .writeQuote: "Zitat schreiben...",
            .authorOptional: "Autor (optional)",
            .resetDefaults: "Zurücksetzen",
            .defaultQuote: "Arbeite weiter, um Großartiges zu erreichen!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "Die Bildschirmzeit endet in 5 Minuten.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "Die Bildschirmzeit ist abgelaufen.",
            .dur30m: "30m",
            .dur1h: "1h",
            .dur2h: "2h",
            .dur4h: "4h",
            .dur8h: "8h",
            .dur12h: "12h",
            .hour1: "1 Stunde",
            .hour4: "4 Stunden",
            .hour8: "8 Stunden",
            .hour12: "12 Stunden",
            .unlimited: "Unbegrenzt",
        ],

        // MARK: Japanese
        .japanese: [
            .appTagline: "画面をスリープさせない！",
            .keepScreenAwake: "画面をオンに保つ",
            .active: "アクティブ",
            .sessionCount: "セッション",
            .todayMinutes: "今日",
            .profileMeeting: "ミーティング",
            .profileDeepWork: "集中作業",
            .profileLongCompute: "長時間計算",
            .profileOvernight: "一晩中",
            .profileUnlimited: "無制限",
            .profileMeetingDesc: "1時間",
            .profileDeepWorkDesc: "4時間",
            .profileLongComputeDesc: "8時間",
            .profileOvernightDesc: "12時間",
            .profileUnlimitedDesc: "無制限",
            .quickStart: "クイックスタート",
            .custom: "カスタム",
            .customDuration: "カスタム時間",
            .startButton: "開始",
            .stopButton: "停止",
            .hours: "時間",
            .minutes: "分",
            .screenBrightness: "画面の明るさ",
            .externalMonitor: "外部モニター",
            .settings: "設定",
            .themeMode: "テーマモード",
            .colorPalette: "カラーパレット",
            .language: "言語",
            .editQuotes: "名言を編集",
            .quitApp: "Kapat.maを終了",
            .themeSystem: "システム",
            .themeLight: "ライト",
            .themeDark: "ダーク",
            .paletteEspresso: "エスプレッソ",
            .paletteOcean: "オーシャン",
            .paletteSunset: "サンセット",
            .paletteForest: "フォレスト",
            .paletteLavender: "ラベンダー",
            .paletteCherry: "チェリー",
            .motivationalQuotes: "名言集",
            .writeQuote: "名言を入力...",
            .authorOptional: "著者（任意）",
            .resetDefaults: "デフォルトに戻す",
            .defaultQuote: "偉大なことを成し遂げるために頑張り続けよう！",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "画面オン時間は5分後に終了します。",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "画面オン時間が終了しました。",
            .dur30m: "30分",
            .dur1h: "1時間",
            .dur2h: "2時間",
            .dur4h: "4時間",
            .dur8h: "8時間",
            .dur12h: "12時間",
            .hour1: "1時間",
            .hour4: "4時間",
            .hour8: "8時間",
            .hour12: "12時間",
            .unlimited: "無制限",
        ],

        // MARK: Korean
        .korean: [
            .appTagline: "화면을 끄지 마세요!",
            .keepScreenAwake: "화면 깨우기 유지",
            .active: "활성",
            .sessionCount: "세션",
            .todayMinutes: "오늘",
            .profileMeeting: "회의",
            .profileDeepWork: "집중 작업",
            .profileLongCompute: "장시간 계산",
            .profileOvernight: "밤새",
            .profileUnlimited: "무제한",
            .profileMeetingDesc: "1시간",
            .profileDeepWorkDesc: "4시간",
            .profileLongComputeDesc: "8시간",
            .profileOvernightDesc: "12시간",
            .profileUnlimitedDesc: "무제한",
            .quickStart: "빠른 시작",
            .custom: "사용자 정의",
            .customDuration: "사용자 정의 시간",
            .startButton: "시작",
            .stopButton: "중지",
            .hours: "시간",
            .minutes: "분",
            .screenBrightness: "화면 밝기",
            .externalMonitor: "외부 모니터",
            .settings: "설정",
            .themeMode: "테마 모드",
            .colorPalette: "색상 팔레트",
            .language: "언어",
            .editQuotes: "명언 편집",
            .quitApp: "Kapat.ma 종료",
            .themeSystem: "시스템",
            .themeLight: "라이트",
            .themeDark: "다크",
            .paletteEspresso: "에스프레소",
            .paletteOcean: "오션",
            .paletteSunset: "선셋",
            .paletteForest: "포레스트",
            .paletteLavender: "라벤더",
            .paletteCherry: "체리",
            .motivationalQuotes: "명언 모음",
            .writeQuote: "명언을 입력하세요...",
            .authorOptional: "저자 (선택)",
            .resetDefaults: "기본값으로 재설정",
            .defaultQuote: "위대한 것을 이루기 위해 계속 노력하세요!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "화면 활성 시간이 5분 후에 종료됩니다.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "화면 활성 시간이 종료되었습니다.",
            .dur30m: "30분",
            .dur1h: "1시간",
            .dur2h: "2시간",
            .dur4h: "4시간",
            .dur8h: "8시간",
            .dur12h: "12시간",
            .hour1: "1시간",
            .hour4: "4시간",
            .hour8: "8시간",
            .hour12: "12시간",
            .unlimited: "무제한",
        ],

        // MARK: Chinese (Simplified)
        .chinese: [
            .appTagline: "别让你的屏幕休眠！",
            .keepScreenAwake: "保持屏幕唤醒",
            .active: "活跃",
            .sessionCount: "会话",
            .todayMinutes: "今天",
            .profileMeeting: "会议",
            .profileDeepWork: "深度工作",
            .profileLongCompute: "长时间计算",
            .profileOvernight: "通宵",
            .profileUnlimited: "无限制",
            .profileMeetingDesc: "1小时",
            .profileDeepWorkDesc: "4小时",
            .profileLongComputeDesc: "8小时",
            .profileOvernightDesc: "12小时",
            .profileUnlimitedDesc: "无限制",
            .quickStart: "快速启动",
            .custom: "自定义",
            .customDuration: "自定义时长",
            .startButton: "开始",
            .stopButton: "停止",
            .hours: "小时",
            .minutes: "分钟",
            .screenBrightness: "屏幕亮度",
            .externalMonitor: "外接显示器",
            .settings: "设置",
            .themeMode: "主题模式",
            .colorPalette: "调色板",
            .language: "语言",
            .editQuotes: "编辑名言",
            .quitApp: "退出 Kapat.ma",
            .themeSystem: "系统",
            .themeLight: "浅色",
            .themeDark: "深色",
            .paletteEspresso: "浓缩咖啡",
            .paletteOcean: "海洋",
            .paletteSunset: "日落",
            .paletteForest: "森林",
            .paletteLavender: "薰衣草",
            .paletteCherry: "樱桃",
            .motivationalQuotes: "名言警句",
            .writeQuote: "写一句名言...",
            .authorOptional: "作者（可选）",
            .resetDefaults: "恢复默认",
            .defaultQuote: "继续努力，成就伟大！",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "屏幕唤醒时间将在5分钟后结束。",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "屏幕唤醒时间已结束。",
            .dur30m: "30分钟",
            .dur1h: "1小时",
            .dur2h: "2小时",
            .dur4h: "4小时",
            .dur8h: "8小时",
            .dur12h: "12小时",
            .hour1: "1小时",
            .hour4: "4小时",
            .hour8: "8小时",
            .hour12: "12小时",
            .unlimited: "无限制",
        ],

        // MARK: Arabic
        .arabic: [
            .appTagline: "لا تدع شاشتك تنام!",
            .keepScreenAwake: "إبقاء الشاشة مستيقظة",
            .active: "نشط",
            .sessionCount: "جلسات",
            .todayMinutes: "اليوم",
            .profileMeeting: "اجتماع",
            .profileDeepWork: "عمل عميق",
            .profileLongCompute: "حساب طويل",
            .profileOvernight: "طوال الليل",
            .profileUnlimited: "غير محدود",
            .profileMeetingDesc: "ساعة واحدة",
            .profileDeepWorkDesc: "4 ساعات",
            .profileLongComputeDesc: "8 ساعات",
            .profileOvernightDesc: "12 ساعة",
            .profileUnlimitedDesc: "غير محدود",
            .quickStart: "بدء سريع",
            .custom: "مخصص",
            .customDuration: "مدة مخصصة",
            .startButton: "بدء",
            .stopButton: "إيقاف",
            .hours: "ساعات",
            .minutes: "دقيقة",
            .screenBrightness: "سطوع الشاشة",
            .externalMonitor: "شاشة خارجية",
            .settings: "الإعدادات",
            .themeMode: "وضع السمة",
            .colorPalette: "لوحة الألوان",
            .language: "اللغة",
            .editQuotes: "تعديل الاقتباسات",
            .quitApp: "إنهاء Kapat.ma",
            .themeSystem: "النظام",
            .themeLight: "فاتح",
            .themeDark: "داكن",
            .paletteEspresso: "إسبريسو",
            .paletteOcean: "محيط",
            .paletteSunset: "غروب",
            .paletteForest: "غابة",
            .paletteLavender: "لافندر",
            .paletteCherry: "كرز",
            .motivationalQuotes: "اقتباسات تحفيزية",
            .writeQuote: "اكتب اقتباساً...",
            .authorOptional: "المؤلف (اختياري)",
            .resetDefaults: "إعادة التعيين",
            .defaultQuote: "استمر في العمل لتحقيق أشياء عظيمة!",
            .notifWarningTitle: "🔓 Kapat.ma",
            .notifWarningBody: "سينتهي وقت الشاشة النشطة خلال 5 دقائق.",
            .notifEndTitle: "🔒 Kapat.ma",
            .notifEndBody: "انتهى وقت الشاشة النشطة.",
            .dur30m: "30د",
            .dur1h: "1س",
            .dur2h: "2س",
            .dur4h: "4س",
            .dur8h: "8س",
            .dur12h: "12س",
            .hour1: "ساعة واحدة",
            .hour4: "4 ساعات",
            .hour8: "8 ساعات",
            .hour12: "12 ساعة",
            .unlimited: "غير محدود",
        ],
    ]
}
