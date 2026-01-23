//
//  SoundService.swift
//  Mathaxy
//
//  音效服务
//  负责管理游戏音效和语音
//

import AVFoundation
import UIKit

// MARK: - 音效服务类
class SoundService: ObservableObject {
    
    // MARK: - 单例
    static let shared = SoundService()
    
    // MARK: - 音频播放器
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - 音效开关
    @Published var isSoundEnabled: Bool = true
    
    // MARK: - 音乐开关
    @Published var isMusicEnabled: Bool = true
    
    // MARK: - 震动反馈开关
    @Published var isHapticEnabled: Bool = true
    
    private init() {
        // 初始化音频会话
        setupAudioSession()
        
        // 加载设置
        loadSettings()
    }
    
    // MARK: - 设置音频会话
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("设置音频会话失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 加载设置
    private func loadSettings() {
        if let settings = StorageService.shared.loadAppSettings() {
            isSoundEnabled = settings.isSoundEnabled
            isMusicEnabled = settings.isMusicEnabled
            isHapticEnabled = settings.isHapticEnabled
        }
    }
    
    // MARK: - 播放音效
    
    /// 播放答对音效
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "correct", withExtension: "m4a")
        playHapticFeedback(style: .light)
    }
    
    /// 播放答错音效
    func playIncorrectSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "incorrect", withExtension: "m4a")
        playHapticFeedback(style: .medium)
    }
    
    /// 播放超时音效
    func playTimeoutSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "timeout", withExtension: "m4a")
        playHapticFeedback(style: .medium)
    }
    
    /// 播放获得勋章音效
    func playBadgeEarnedSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "badge_earned", withExtension: "m4a")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放解锁角色音效
    func playCharacterUnlockedSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "character_unlocked", withExtension: "m4a")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放跳关音效
    func playSkipLevelSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "skip_level", withExtension: "m4a")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放成功音效
    func playSuccessSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "success", withExtension: "m4a")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放游戏完成音效
    func playGameCompleteSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "game_complete", withExtension: "m4a")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放通用错误音效
    func playErrorSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "error", withExtension: "m4a")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放按钮点击音效
    func playButtonClickSound() {
        guard isSoundEnabled else { return }
        // Q版音效使用 .m4a 格式，旧版音效使用 .mp3 格式
        playSound(named: "button_click", withExtension: "m4a")
        playHapticFeedback(style: .light)
    }
    
    // MARK: - 播放语音
    
    /// 播放答对语音
    func playCorrectVoice(language: AppLanguage) {
        guard isSoundEnabled else { return }
        let voiceFileName = getVoiceFileName(for: "correct", language: language)
        // Q版语音使用 .m4a 格式，旧版语音使用 .mp3 格式
        let ext = voiceFileName.hasPrefix("q_voice_") ? "m4a" : "mp3"
        playSound(named: voiceFileName, withExtension: ext)
    }
    
    /// 播放答错语音
    func playIncorrectVoice(language: AppLanguage) {
        guard isSoundEnabled else { return }
        let voiceFileName = getVoiceFileName(for: "incorrect", language: language)
        // Q版语音使用 .m4a 格式，旧版语音使用 .mp3 格式
        let ext = voiceFileName.hasPrefix("q_voice_") ? "m4a" : "mp3"
        playSound(named: voiceFileName, withExtension: ext)
    }
    
    /// 播放鼓励语音
    func playEncouragementVoice(language: AppLanguage) {
        guard isSoundEnabled else { return }
        let voiceFileName = getVoiceFileName(for: "encouragement", language: language)
        // Q版语音使用 .m4a 格式，旧版语音使用 .mp3 格式
        let ext = voiceFileName.hasPrefix("q_voice_") ? "m4a" : "mp3"
        playSound(named: voiceFileName, withExtension: ext)
    }
    
    /// 播放角色问候语音
    func playCharacterGreetingVoice(characterType: CharacterType, language: AppLanguage) {
        guard isSoundEnabled else { return }
        let characterName = characterType == .panda ? "panda" : "rabbit"
        let voiceFileName = getVoiceFileName(for: "\(characterName)_greeting", language: language)
        // Q版语音使用 .m4a 格式，旧版语音使用 .mp3 格式
        let ext = voiceFileName.hasPrefix("q_voice_") ? "m4a" : "mp3"
        playSound(named: voiceFileName, withExtension: ext)
    }
    
    /// 批量测试所有语音文件
    func testAllVoiceFiles() {
        print("🔊 测试所有语音文件...")
        
        // 测试所有语言的所有语音类型
        for language in AppLanguage.allCases {
            print("\n🌍 测试语言: \(language.displayName)")
            
            // 测试答对语音
            let correctFileName = getVoiceFileName(for: "correct", language: language)
            if let _ = Bundle.main.url(forResource: correctFileName, withExtension: "mp3") {
                print("✅ 答对语音: \(correctFileName)")
            } else {
                print("❌ 答对语音缺失: \(correctFileName)")
            }
            
            // 测试答错语音
            let incorrectFileName = getVoiceFileName(for: "incorrect", language: language)
            if let _ = Bundle.main.url(forResource: incorrectFileName, withExtension: "mp3") {
                print("✅ 答错语音: \(incorrectFileName)")
            } else {
                print("❌ 答错语音缺失: \(incorrectFileName)")
            }
            
            // 测试鼓励语音
            let encouragementFileName = getVoiceFileName(for: "encouragement", language: language)
            if let _ = Bundle.main.url(forResource: encouragementFileName, withExtension: "mp3") {
                print("✅ 鼓励语音: \(encouragementFileName)")
            } else {
                print("❌ 鼓励语音缺失: \(encouragementFileName)")
            }
            
            // 测试熊猫问候语音
            let pandaGreetingFileName = getVoiceFileName(for: "panda_greeting", language: language)
            if let _ = Bundle.main.url(forResource: pandaGreetingFileName, withExtension: "mp3") {
                print("✅ 熊猫问候: \(pandaGreetingFileName)")
            } else {
                print("❌ 熊猫问候缺失: \(pandaGreetingFileName)")
            }
            
            // 测试兔子问候语音
            let rabbitGreetingFileName = getVoiceFileName(for: "rabbit_greeting", language: language)
            if let _ = Bundle.main.url(forResource: rabbitGreetingFileName, withExtension: "mp3") {
                print("✅ 兔子问候: \(rabbitGreetingFileName)")
            } else {
                print("❌ 兔子问候缺失: \(rabbitGreetingFileName)")
            }
        }
        
        print("\n📝 测试完成！")
    }
    
    // MARK: - 播放音效（私有方法）
    private func playSound(named name: String, withExtension ext: String) {
        // Q版音效映射策略：优先加载 Q 版新命名音效，若资源缺失则回退旧命名（兼容）
        // 这样可以确保即使 Q 版音效文件缺失，应用仍能正常播放原有音效
        let qStyleName = getQStyleName(for: name)
        
        // Q版音效使用 .m4a 格式，旧版音效使用传入的扩展名（通常是 .mp3）
        let qStyleExt = "m4a"
        
        // 首先尝试加载 Q 版音效（使用 .m4a 扩展名）
        if let url = Bundle.main.url(forResource: qStyleName, withExtension: qStyleExt) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return
            } catch {
                print("播放 Q 版音效失败 \(qStyleName).\(qStyleExt): \(error.localizedDescription)")
            }
        }
        
        // Q 版音效不存在，回退到旧命名音效（使用传入的扩展名，兼容性保障）
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("找不到音效文件: \(name).\(ext) (Q版: \(qStyleName).\(qStyleExt) 也不存在)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("播放音效失败: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 获取 Q 版音效名称
    /// 将旧音效名称映射到 Q 版音效名称
    /// - Parameter name: 旧音效名称（如 "correct", "button_click"）
    /// - Returns: Q 版音效名称（如 "q_sfx_correct_01", "q_sfx_button_click_01"）
    private func getQStyleName(for name: String) -> String {
        // Q版音效映射表：旧名称 -> Q版名称
        let qStyleMapping: [String: String] = [
            // 答题反馈
            "correct": "q_sfx_correct_01",
            "incorrect": "q_sfx_incorrect_01",
            
            // 游戏状态
            "timeout": "q_sfx_timeout_01",
            "level_complete": "q_sfx_level_complete_01",
            "game_over": "q_sfx_game_over_01",
            "game_complete": "q_sfx_game_complete_01",
            
            // 成就与角色
            "badge_earned": "q_sfx_badge_earned_01",
            "character_unlocked": "q_sfx_character_unlocked_01",
            
            // 操作反馈
            "error": "q_sfx_error_01",
            "success": "q_sfx_success_01",
            "skip_level": "q_sfx_skip_level_01",
            
            // UI 交互
            "button_click": "q_sfx_button_click_01"
        ]
        
        return qStyleMapping[name] ?? name
    }
    
    // MARK: - 获取语音文件名
    private func getVoiceFileName(for type: String, language: AppLanguage) -> String {
        let languageCode = language.rawValue
        // Q版语音映射策略：优先使用 Q 版语音，若不存在则回退旧命名
        // 这样可以确保即使 Q 版语音文件缺失，应用仍能正常播放原有语音
        let qStyleVoiceName = "q_voice_\(type)_\(languageCode)_01"
        
        // 检查 Q 版语音是否存在
        if let _ = Bundle.main.url(forResource: qStyleVoiceName, withExtension: "m4a") {
            return qStyleVoiceName
        }
        
        // Q 版语音不存在，回退到旧命名（兼容性保障）
        return "\(type)_\(languageCode)"
    }
    
    // MARK: - 震动反馈
    
    /// 播放震动反馈
    /// - Parameter style: 震动样式
    private func playHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticEnabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    /// 播放成功震动
    func playSuccessHaptic() {
        guard isHapticEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// 播放警告震动
    func playWarningHaptic() {
        guard isHapticEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    /// 播放错误震动
    func playErrorHaptic() {
        guard isHapticEnabled else { return }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - 停止所有音效
    func stopAllSounds() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // MARK: - 更新设置
    func updateSettings(isSoundEnabled: Bool? = nil, isMusicEnabled: Bool? = nil, isHapticEnabled: Bool? = nil) {
        if let isSoundEnabled = isSoundEnabled {
            self.isSoundEnabled = isSoundEnabled
        }
        
        if let isMusicEnabled = isMusicEnabled {
            self.isMusicEnabled = isMusicEnabled
        }
        
        if let isHapticEnabled = isHapticEnabled {
            self.isHapticEnabled = isHapticEnabled
        }
        
        // 保存到应用设置
        if var settings = StorageService.shared.loadAppSettings() {
            settings.isSoundEnabled = self.isSoundEnabled
            settings.isMusicEnabled = self.isMusicEnabled
            settings.isHapticEnabled = self.isHapticEnabled
            StorageService.shared.saveAppSettings(settings)
        }
    }
}

// MARK: - 音效类型枚举
enum SoundType {
    case correct
    case incorrect
    case timeout
    case badgeEarned
    case characterUnlocked
    case skipLevel
    case buttonClick
}

// MARK: - 语音类型枚举
enum VoiceType {
    case correct
    case incorrect
    case encouragement
    case characterGreeting(CharacterType)
}
