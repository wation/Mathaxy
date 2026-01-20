import Foundation

// MARK: - 资源管理器
/// 管理应用中所有的资源文件（图片、音效、字体等）
struct AppResources {
    
    // MARK: - 应用图标名称
    struct Icons {
        // 导航栏图标
        static let home = "house.fill"
        static let game = "gamecontroller.fill"
        static let achievement = "star.fill"
        static let settings = "gear"
        
        // 游戏相关图标
        static let correct = "checkmark.circle.fill"
        static let incorrect = "xmark.circle.fill"
        static let timer = "timer"
        static let score = "star.fill"
        static let level = "flag.fill"
        
        // 成就系统图标
        static let badge = "medal.fill"
        static let lock = "lock.fill"
        static let unlock = "lock.open.fill"
        static let character = "person.fill"
        
        // 证书和分享
        static let certificate = "document.fill"
        static let share = "square.and.arrow.up"
        static let download = "arrow.down"
        
        // 设置和其他
        static let language = "globe"
        static let sound = "speaker.wave.2.fill"
        static let music = "music.note"
        static let vibration = "iphone.radiowaves.left.and.right"
        static let info = "info.circle"
    }
    
    // MARK: - 音效文件名（需要在 Sounds 文件夹中添加实际的音频文件）
    struct Sounds {
        // 游戏音效
        static let correctAnswer = "correct_answer.mp3"
        static let incorrectAnswer = "incorrect_answer.mp3"
        static let timeout = "timeout.mp3"
        static let levelComplete = "level_complete.mp3"
        static let gameOver = "game_over.mp3"
        
        // 成就系统音效
        static let badgeEarned = "badge_earned.mp3"
        static let characterUnlocked = "character_unlocked.mp3"
        static let levelUnlocked = "level_unlocked.mp3"
        
        // UI 交互音效
        static let buttonTap = "button_tap.mp3"
        static let notification = "notification.mp3"
    }
    
    // MARK: - 背景音乐文件名（需要在 Sounds 文件夹中添加实际的音乐文件）
    struct Music {
        static let backgroundMusic = "background_music.mp3"
        static let levelSelectMusic = "level_select_music.mp3"
        static let gameOverMusic = "game_over_music.mp3"
    }
    
    // MARK: - 图片资源名称（需要在 Assets.xcassets 中添加实际的图片）
    struct Images {
        // 应用图标和启动屏
        static let appIcon = "AppIcon"
        static let launchImage = "LaunchImage"
        
        // 背景图片
        static let homeBackground = "home_background"
        static let gameBackground = "game_background"
        static let levelSelectBackground = "level_select_background"
        
        // 卡通角色
        static let pandaCharacter = "panda_character"
        static let rabbitCharacter = "rabbit_character"
        
        // 勋章图片
        static let levelCompleteBadge = "level_complete_badge"
        static let speedMasterBadge = "speed_master_badge"
        static let quizGeniusBadge = "quiz_genius_badge"
        static let persistenceMasterBadge = "persistence_master_badge"
        
        // 按钮和UI元素
        static let startGameButton = "start_game_button"
        static let continueGameButton = "continue_game_button"
        static let settingsButton = "settings_button"
        static let closeButton = "close_button"
        
        // 游戏元素
        static let correctIcon = "correct_icon"
        static let incorrectIcon = "incorrect_icon"
        static let timerIcon = "timer_icon"
        static let levelIcon = "level_icon"
        
        // 其他
        static let emptyState = "empty_state"
        static let errorState = "error_state"
    }
    
    // MARK: - 资源验证
    /// 检查所有必需的资源是否存在
    static func validateResources() {
        // 这个方法可以用于运行时检查资源是否都已正确添加
        // 可以在 AppDelegate 或启动时调用
    }
}

// MARK: - 资源文件清单
/*
 必需添加的资源文件列表：
 
 1. 音效文件（添加到 Resources/Sounds/）
    - correct_answer.mp3: 答对时的提示音
    - incorrect_answer.mp3: 答错时的提示音
    - timeout.mp3: 超时时的提示音
    - level_complete.mp3: 关卡完成时的声音
    - game_over.mp3: 游戏结束时的声音
    - badge_earned.mp3: 获得勋章时的声音
    - character_unlocked.mp3: 解锁角色时的声音
    - level_unlocked.mp3: 解锁关卡时的声音
    - button_tap.mp3: 按钮点击音
    - notification.mp3: 通知提示音
 
 2. 背景音乐（添加到 Resources/Sounds/）
    - background_music.mp3: 游戏背景音乐
    - level_select_music.mp3: 关卡选择屏幕背景音乐
    - game_over_music.mp3: 游戏结束屏幕背景音乐
 
 3. 图片文件（添加到 Assets.xcassets）
    - AppIcon: 应用图标（所有尺寸）
    - LaunchImage: 启动屏幕
    - home_background: 首页背景
    - game_background: 游戏屏幕背景
    - level_select_background: 关卡选择背景
    - panda_character: 熊猫卡通角色
    - rabbit_character: 兔子卡通角色
    - level_complete_badge: 关卡完成勋章
    - speed_master_badge: 神速小能手勋章
    - quiz_genius_badge: 答题小天才勋章
    - persistence_master_badge: 坚持小达人勋章
    - start_game_button: 开始游戏按钮
    - continue_game_button: 继续游戏按钮
    - settings_button: 设置按钮
    - close_button: 关闭按钮
    - correct_icon: 正确图标
    - incorrect_icon: 错误图标
    - timer_icon: 计时器图标
    - level_icon: 关卡图标
    - empty_state: 空状态插图
    - error_state: 错误状态插图
 
 注意：
 - 所有音频文件应该是 MP3 格式
 - 图片文件应该提供 1x, 2x, 3x 的分辨率
 - 推荐使用 PDF 格式的矢量图，系统会自动生成各个分辨率
 - 应用图标需要不同尺寸：1024x1024（App Store）, 180x180（iPhone）等
 */
