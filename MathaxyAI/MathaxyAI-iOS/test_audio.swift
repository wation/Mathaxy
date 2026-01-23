import Foundation
import AVFoundation

// 测试语音播放功能
func testAudioPlayback() {
    print("🎵 开始测试语音播放功能...")
    
    let audioManager = AudioPlayerManager.shared
    let languages = ["zh-Hans", "zh-Hant", "en", "ja", "ko", "es", "pt"]
    let voiceTypes: [VoiceType] = [.correct, .incorrect, .encouragement, .pandaGreeting, .rabbitGreeting]
    
    // 测试每种语言的每种语音类型
    for language in languages {
        print("\n🌍 测试语言: \(language)")
        
        for voiceType in voiceTypes {
            print("🔊 播放 \(voiceType.rawValue)...")
            audioManager.playVoice(for: voiceType, language: language)
            
            // 等待语音播放完成（假设每个语音不超过2秒）
            Thread.sleep(forTimeInterval: 2.0)
        }
    }
    
    print("\n✅ 语音播放测试完成！")
}

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
    func playVoice(for type: VoiceType, language: String = "zh-Hans") {
        let soundName = getSoundName(for: type, language: language)
        playSound(named: soundName)
    }
    
    // MARK: - 获取对应语言的音效文件名
    private func getSoundName(for type: VoiceType, language: String) -> String {
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
enum VoiceType: String {
    case correct = "correct"
    case incorrect = "incorrect"
    case encouragement = "encouragement"
    case pandaGreeting = "panda_greeting"
    case rabbitGreeting = "rabbit_greeting"
}

// 运行测试
testAudioPlayback()