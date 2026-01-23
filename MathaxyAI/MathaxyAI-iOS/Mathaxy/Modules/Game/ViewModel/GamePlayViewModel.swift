import Foundation
import AVFoundation

// MARK: - 语音播放管理器
class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayerManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let soundQueue = DispatchQueue(label: "com.mathaxy.soundQueue")
    
    private override init() {}
    
    // MARK: - 播放音效
    func playSound(named soundName: String) {
        soundQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 检查是否已经缓存了播放器
            if let player = self.audioPlayers[soundName] {
                if player.isPlaying {
                    player.stop()
                }
                player.currentTime = 0
                player.play()
                return
            }
            
            // 尝试加载音效文件
            guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: nil) else {
                print("❌ 音效文件不存在: \(soundName)")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.delegate = self
                player.prepareToPlay()
                self.audioPlayers[soundName] = player
                player.play()
            } catch {
                print("❌ 加载音效失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 根据语言播放语音
    func playVoice(for type: GameVoiceType, language: String = "zh-Hans") {
        let soundName = getSoundName(for: type, language: language)
        playSound(named: soundName)
    }
    
    // MARK: - 获取对应语言的音效文件名
    private func getSoundName(for type: GameVoiceType, language: String) -> String {
        switch type {
        case .correct:
            return "correct_\(language)"
        case .incorrect:
            return "incorrect_\(language)"
        case .encouragement:
            return "encouragement_\(language)"
        case .pandaGreeting:
            return "panda_greeting_\(language)"
        case .rabbitGreeting:
            return "rabbit_greeting_\(language)"
        }
    }
    
    // MARK: - 清理缓存
    func clearCache() {
        audioPlayers.removeAll()
    }
}

// MARK: - 语音类型枚举
enum GameVoiceType: String {
    case correct = "correct"
    case incorrect = "incorrect"
    case encouragement = "encouragement"
    case pandaGreeting = "panda_greeting"
    case rabbitGreeting = "rabbit_greeting"
}

// MARK: - 游戏播放视图模型
class GamePlayViewModel: ObservableObject {
    // MARK: - 游戏状态
    @Published var currentQuestion: Question?
    @Published var score = 0
    @Published var timeRemaining = 60
    @Published var isGameOver = false
    @Published var isCorrect = false
    @Published var isGameCompleted = false
    @Published var progress = 0.0
    @Published var userInputAnswer = ""
    @Published var hasInputError = false
    @Published var showResult = false
    @Published var showGameComplete = false
    @Published var isCorrectAnswer = false
    
    // MARK: - 游戏数据
    var gameSession: GameSession?
    var level = 1
    var currentQuestionIndex = 0
    var totalQuestions = 10
    
    // MARK: - 依赖
    private let audioPlayer = AudioPlayerManager.shared
    private let languageManager = LanguageManager.shared
    
    // MARK: - 初始化
    init(level: Int) {
        self.level = level
        // 初始化游戏
    }
    
    // MARK: - 游戏逻辑
    func checkAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        
        if let answerInt = Int(answer), answerInt == question.correctAnswer {
            handleCorrectAnswer()
        } else {
            handleIncorrectAnswer()
        }
    }
    
    // MARK: - 暂停游戏
    func pauseGame() {
        // 暂停游戏逻辑
    }
    
    // MARK: - 播放按钮点击音效
    func playButtonClickSound() {
        audioPlayer.playSound(named: "button_click")
    }
    
    // MARK: - 输入数字
    func inputDigit(_ digit: Int) {
        if userInputAnswer.count < 3 {
            userInputAnswer += String(digit)
        }
    }
    
    // MARK: - 清除所有输入
    func clearAllInput() {
        userInputAnswer = ""
        hasInputError = false
    }
    
    // MARK: - 正确回答处理
    private func handleCorrectAnswer() {
        score += 10
        isCorrect = true
        
        // 播放正确回答的语音
        let currentLanguage = languageManager.currentLanguage
        audioPlayer.playVoice(for: GameVoiceType.correct, language: currentLanguage)
        
        // 延迟后显示下一题
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isCorrect = false
            self.nextQuestion()
        }
    }
    
    // MARK: - 错误回答处理
    private func handleIncorrectAnswer() {
        isCorrect = false
        
        // 播放错误回答的语音
        let currentLanguage = languageManager.currentLanguage
        audioPlayer.playVoice(for: GameVoiceType.incorrect, language: currentLanguage)
        
        // 播放鼓励语
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.audioPlayer.playVoice(for: GameVoiceType.encouragement, language: currentLanguage)
        }
    }
    
    // MARK: - 下一题
    private func nextQuestion() {
        // 加载下一题
    }
    
    // MARK: - 开始游戏
    func startGame() {
        // 播放角色问候语
        let currentLanguage = languageManager.currentLanguage
        audioPlayer.playVoice(for: GameVoiceType.pandaGreeting, language: currentLanguage)
    }
}

// MARK: - 语言管理器
class LanguageManager: NSObject {
    static let shared = LanguageManager()
    
    var currentLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: "currentLanguage") ?? "zh-Hans"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "currentLanguage")
        }
    }
    
    private override init() {}
    
    // MARK: - 支持的语言列表
    func supportedLanguages() -> [String] {
        return ["zh-Hans", "zh-Hant", "en", "ja", "ko", "es", "pt"]
    }
    
    // MARK: - 获取语言显示名称
    func displayName(for language: String) -> String {
        switch language {
        case "zh-Hans":
            return "简体中文"
        case "zh-Hant":
            return "繁体中文"
        case "en":
            return "English"
        case "ja":
            return "日本語"
        case "ko":
            return "한국어"
        case "es":
            return "Español"
        case "pt":
            return "Português"
        default:
            return language
        }
    }
}