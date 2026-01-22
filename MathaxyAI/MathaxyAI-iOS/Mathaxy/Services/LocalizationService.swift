//
//  LocalizationService.swift
//  Mathaxy
//
//  本地化服务
//  负责管理多语言支持
//

import Foundation

// MARK: - 本地化服务类
class LocalizationService: ObservableObject {
    
    // MARK: - 单例
    static let shared = LocalizationService()
    
    // MARK: - 当前语言
    @Published var currentLanguage: AppLanguage = .chinese {
        didSet {
            updateLanguage()
        }
    }
    
    private init() {
        // 初始化时加载保存的语言设置
        loadLanguage()
    }
    
    // MARK: - 语言管理
    
    /// 加载保存的语言设置
    private func loadLanguage() {
        if let settings = StorageService.shared.loadAppSettings() {
            currentLanguage = settings.language
        } else {
            // 如果没有保存的设置，使用系统语言
            currentLanguage = AppSettings.getSystemLanguage()
        }
    }
    
    /// 更新语言
    private func updateLanguage() {
        // 更新UserDefaults
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: "currentLanguage")
        
        // 通知系统语言已更改
        UserDefaults.standard.synchronize()
        
        // 发送通知
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
    
    /// 切换语言
    func switchLanguage(to newLanguage: AppLanguage) {
        currentLanguage = newLanguage
        
        // 保存到应用设置
        if var settings = StorageService.shared.loadAppSettings() {
            settings.switchLanguage(to: newLanguage)
            StorageService.shared.saveAppSettings(settings)
        }
    }
    
    // MARK: - 本地化字符串获取
    
    /// 获取本地化字符串
    /// - Parameter key: 字符串键
    /// - Returns: 本地化字符串
    func localizedString(for key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    /// 获取带参数的本地化字符串
    /// - Parameters:
    ///   - key: 字符串键
    ///   - arguments: 参数
    /// - Returns: 本地化字符串
    func localizedString(for key: String, arguments: CVarArg...) -> String {
        let format = localizedString(for: key)
        return String(format: format, arguments: arguments)
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

// MARK: - String扩展（便捷方法）
extension String {
    /// 获取本地化字符串
    var localized: String {
        return LocalizationService.shared.localizedString(for: self)
    }
    
    /// 获取带参数的本地化字符串
    func localized(arguments: CVarArg...) -> String {
        return LocalizationService.shared.localizedString(for: self, arguments: arguments)
    }
}

// MARK: - 本地化字符串键定义
struct LocalizedKeys {
    
    // MARK: - 通用
    static let appName = "app_name"
    static let ok = "ok"
    static let cancel = "cancel"
    static let confirm = "confirm"
    static let back = "back"
    static let next = "next"
    static let retry = "retry"
    static let save = "save"
    static let share = "share"
    static let settings = "settings"
    static let achievement = "achievement"
    static let home = "home"
    
    // MARK: - 登录
    static let guestLogin = "guest_login"
    static let parentBind = "parent_bind"
    static let nickname = "nickname"
    static let enterNickname = "enter_nickname"
    static let setNicknameHint = "set_nickname_hint"
    static let welcome = "welcome"
    static let saving = "saving"
    
    // MARK: - 游戏
    static let level = "level"
    static let question = "question"
    static let time = "time"
    static let score = "score"
    static let startGame = "start_game"
    static let continueGame = "continue_game"
    static let levelSelect = "level_select"
    static let currentLevel = "current_level"
    static let unlocked = "unlocked"
    static let locked = "locked"
    static let completed = "completed"
    
    // MARK: - 关卡
    static let levelDescription = "level_description"
    static let totalTimeMode = "total_time_mode"
    static let perQuestionMode = "per_question_mode"
    static let minutes = "minutes"
    static let seconds = "seconds"
    static let perQuestion = "per_question"
    
    // MARK: - 结果
    static let result = "result"
    static let timeSpent = "time_spent"
    static let congratulations = "congratulations"
    static let tryAgain = "try_again"
    static let completedLevel = "completed_level"
    static let failedLevel = "failed_level"
    static let correctAnswers = "correct_answers"
    static let errorCount = "error_count"
    static let generateCertificate = "generate_certificate"
    static let totalTime = "total_time"
    static let accuracy = "accuracy"
    static let earnedBadge = "earned_badge"
    
    // MARK: - 失败机制
    static let watchAdRetry = "watch_ad_retry"
    static let backToHome = "back_to_home"
    static let adDuration = "ad_duration"
    static let adDescription = "ad_description"
    
    // MARK: - 跳关
    static let skipLevel = "skip_level"
    static let skipLevelSuccess = "skip_level_success"
    static let skipToLevel = "skip_to_level"
    
    // MARK: - 勋章
    static let badge = "badge"
    static let badges = "badges"
    static let earnedBadges = "earned_badges"
    static let totalBadges = "total_badges"
    static let levelCompleteBadge = "level_complete_badge"
    static let skipLevelBadge = "skip_level_badge"
    static let perfectLevelBadge = "perfect_level_badge"
    static let consecutiveLoginBadge = "consecutive_login_badge"
    
    // MARK: - 卡通角色
    static let guideCharacter = "guide_character"
    static let panda = "panda"
    static let rabbit = "rabbit"
    static let unlockCharacter = "unlock_character"
    static let unlockThreshold = "unlock_threshold"
    static let characterMessage = "character_message"
    
    // MARK: - 连续登录
    static let consecutiveLogin = "consecutive_login"
    static let consecutiveDays = "consecutive_days"
    static let loginStreak = "login_streak"
    static let keepGoing = "keep_going"
    
    // MARK: - 奖状
    static let certificate = "certificate"
    static let electronicCertificate = "electronic_certificate"
    static let saveToAlbum = "save_to_album"
    static let shareToSocial = "share_to_social"
    static let printHint = "print_hint"
    static let certificateTitle = "certificate_title"
    static let certificateNickname = "certificate_nickname"
    static let certificateTime = "certificate_time"
    static let certificateBadges = "certificate_badges"
    static let shareMessageTemplate = "share_message_template"
    static let certificateOfAchievement = "certificate_of_achievement"
    static let presentedTo = "presented_to"
    static let saveFailed = "save_failed"
    static let saveSuccess = "save_success"
    static let perfectBadgeUnlocked = "perfect_badge_unlocked"
    static let newCharacterUnlocked = "new_character_unlocked"
    static let perfectScore = "perfect_score"
    static let excellentScore = "excellent_score"
    static let goodScore = "good_score"
    static let passedScore = "passed_score"
    
    // MARK: - 评价
    static let perfectPerformance = "perfect_performance"
    static let excellentPerformance = "excellent_performance"
    static let goodPerformance = "good_performance"
    static let needsImprovement = "needs_improvement"
    static let practiceMore = "practice_more"
    static let tryFaster = "try_faster"
    static let improveAccuracy = "improve_accuracy"
    static let keepUpGoodWork = "keep_up_good_work"
    static let nextLevelUnlocked = "next_level_unlocked"
    static let retryCurrentLevel = "retry_current_level"
    static let tryNextLevel = "try_next_level"
    static let allLevelsCompleted = "all_levels_completed"
    static let myBadges = "my_badges"
    static let earned = "earned"
    static let total = "total"
    static let earnedDate = "earned_date"
    static let relatedLevel = "related_level"
    
    // MARK: - 设置
    static let languageSettings = "language_settings"
    static let soundSettings = "sound_settings"
    static let musicSettings = "music_settings"
    static let hapticSettings = "haptic_settings"
    static let aboutApp = "about_app"
    static let version = "version"
    static let resetData = "reset_data"
    static let resetDataWarning = "reset_data_warning"
    static let resetDataConfirm = "reset_data_confirm"
    
    // MARK: - 音效
    static let correct = "correct"
    static let incorrect = "incorrect"
    static let correctAnswer = "correct_answer"
    static let timeout = "timeout"
    static let badgeEarned = "badge_earned"
    static let characterUnlocked = "character_unlocked"
    
    // MARK: - 权限
    static let photoLibraryPermission = "photo_library_permission"
    static let photoLibraryPermissionDescription = "photo_library_permission_description"
    static let permissionDenied = "permission_denied"
    static let goToSettings = "go_to_settings"
    
    // MARK: - 其他
    static let loading = "loading"
    static let pleaseWait = "please_wait"
    static let noData = "no_data"
    static let errorOccurred = "error_occurred"
    static let networkError = "network_error"
    static let success = "success"
    static let failed = "failed"
    static let close = "close"
    static let done = "done"
}

// MARK: - 本地化字符串使用示例
/*
// 在代码中使用：
let title = LocalizedKeys.appName.localized
let welcomeMessage = LocalizedKeys.welcome.localized(arguments: nickname)
let levelText = LocalizedKeys.level.localized(arguments: currentLevel)

// 在SwiftUI中使用：
Text(LocalizedKeys.appName.localized)
Text(LocalizedKeys.welcome.localized(arguments: userProfile.nickname))
*/
