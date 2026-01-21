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
        playSound(named: "correct", withExtension: "mp3")
        playHapticFeedback(style: .light)
    }
    
    /// 播放答错音效
    func playIncorrectSound() {
        guard isSoundEnabled else { return }
        playSound(named: "incorrect", withExtension: "mp3")
        playHapticFeedback(style: .medium)
    }
    
    /// 播放超时音效
    func playTimeoutSound() {
        guard isSoundEnabled else { return }
        playSound(named: "timeout", withExtension: "mp3")
        playHapticFeedback(style: .medium)
    }
    
    /// 播放获得勋章音效
    func playBadgeEarnedSound() {
        guard isSoundEnabled else { return }
        playSound(named: "badge_earned", withExtension: "mp3")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放解锁角色音效
    func playCharacterUnlockedSound() {
        guard isSoundEnabled else { return }
        playSound(named: "character_unlocked", withExtension: "mp3")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放跳关音效
    func playSkipLevelSound() {
        guard isSoundEnabled else { return }
        playSound(named: "skip_level", withExtension: "mp3")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放成功音效
    func playSuccessSound() {
        guard isSoundEnabled else { return }
        playSound(named: "success", withExtension: "mp3")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放游戏完成音效
    func playGameCompleteSound() {
        guard isSoundEnabled else { return }
        playSound(named: "game_complete", withExtension: "mp3")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放通用错误音效
    func playErrorSound() {
        guard isSoundEnabled else { return }
        playSound(named: "error", withExtension: "mp3")
        playHapticFeedback(style: .heavy)
    }
    
    /// 播放按钮点击音效
    func playButtonClickSound() {
        guard isSoundEnabled else { return }
        playSound(named: "button_click", withExtension: "mp3")
        playHapticFeedback(style: .light)
    }
    
    // MARK: - 播放语音
    
    /// 播放答对语音
    func playCorrectVoice(language: AppLanguage) {
        guard isSoundEnabled else { return }
        let voiceFileName = getVoiceFileName(for: "correct", language: language)
        playSound(named: voiceFileName, withExtension: "mp3")
    }
    
    /// 播放答错语音
    func playIncorrectVoice(language: AppLanguage) {
        guard isSoundEnabled else { return }
        let voiceFileName = getVoiceFileName(for: "incorrect", language: language)
        playSound(named: voiceFileName, withExtension: "mp3")
    }
    
    /// 播放鼓励语音
    func playEncouragementVoice(language: AppLanguage) {
        guard isSoundEnabled else { return }
        let voiceFileName = getVoiceFileName(for: "encouragement", language: language)
        playSound(named: voiceFileName, withExtension: "mp3")
    }
    
    /// 播放角色问候语音
    func playCharacterGreetingVoice(characterType: CharacterType, language: AppLanguage) {
        guard isSoundEnabled else { return }
        let characterName = characterType == .panda ? "panda" : "rabbit"
        let voiceFileName = getVoiceFileName(for: "\(characterName)_greeting", language: language)
        playSound(named: voiceFileName, withExtension: "mp3")
    }
    
    // MARK: - 播放音效（私有方法）
    private func playSound(named name: String, withExtension ext: String) {
        // 尝试先使用WAV文件
        if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return
            } catch {
                print("播放WAV音效失败: \(error.localizedDescription)")
            }
        }
        
        // 如果WAV文件不存在或播放失败，尝试使用MP3文件
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return
            } catch {
                print("播放\(ext)音效失败: \(error.localizedDescription)")
            }
        }
        
        // 如果所有文件都不存在或播放失败，生成简单的系统音效
        playSystemSound(for: name)
    }
    
    /// 播放系统音效
    private func playSystemSound(for soundName: String) {
        // 使用系统震动反馈代替音效
        switch soundName {
        case "button_click":
            playHapticFeedback(style: .light)
        case "correct", "success", "badge_earned", "character_unlocked", "level_complete":
            playHapticFeedback(style: .medium)
        case "incorrect", "error", "game_over", "timeout":
            playHapticFeedback(style: .heavy)
        default:
            playHapticFeedback(style: .light)
        }
    }
    
    // MARK: - 获取语音文件名
    private func getVoiceFileName(for type: String, language: AppLanguage) -> String {
        let languageCode = language.rawValue
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
