//
//  GameConstants.swift
//  Mathaxy
//
//  游戏常量定义文件
//  包含游戏配置、关卡信息、勋章类型等常量
//

import Foundation

// MARK: - 游戏配置常量
struct GameConstants {
    /// 总关卡数
    static let totalLevels = 10
    
    /// 每关题目数量
    static let questionsPerLevel = 20
    
    /// 每题默认时间（秒）
    static let timePerQuestion = 15.0
    
    /// 单题倒计时模式的最大错误次数
    static let maxErrorsPerLevel = 10
    
    /// 跳关检测需要的连续答题数量
    static let skipCheckCount = 10
    
    /// 连续登录天数要求
    static let consecutiveLoginDays = 7
    
    /// 解锁小熊猫需要的勋章数量
    static let pandaUnlockThreshold = 3
    
    /// 解锁小兔子需要的勋章数量
    static let rabbitUnlockThreshold = 7
}

// MARK: - 游戏模式枚举
enum GameMode {
    /// 总时长模式（第1-5关）
    case totalTime
    
    /// 单题倒计时模式（第6-10关）
    case perQuestion
}

// MARK: - 勋章类型枚举
enum BadgeType: String, Codable, CaseIterable {
    /// 加法小勇士（每通关1关获得）
    case levelComplete = "level_complete"
    
    /// 神速小能手（触发跳关获得）
    case skipLevel = "skip_level"
    
    /// 答题小天才（单关20题全对）
    case perfectLevel = "perfect_level"
    
    /// 坚持小达人（连续登录7天）
    case consecutiveLogin = "consecutive_login"
    
    /// 勋章显示名称（中文）
    var displayName: String {
        switch self {
        case .levelComplete:
            return "加法小勇士"
        case .skipLevel:
            return "神速小能手"
        case .perfectLevel:
            return "答题小天才"
        case .consecutiveLogin:
            return "坚持小达人"
        }
    }
    
    /// 勋章描述
    var description: String {
        switch self {
        case .levelComplete:
            return "每通关1关获得"
        case .skipLevel:
            return "连续10题快速答对获得"
        case .perfectLevel:
            return "单关20题全对获得"
        case .consecutiveLogin:
            return "连续登录7天获得"
        }
    }
    
    /// 勋章系统图标
    var systemImage: String {
        switch self {
        case .levelComplete:
            return "trophy.fill"
        case .skipLevel:
            return "bolt.fill"
        case .perfectLevel:
            return "star.fill"
        case .consecutiveLogin:
            return "flame.fill"
        }
    }
}

// MARK: - 卡通角色类型枚举
enum CharacterType: String, Codable {
    /// 银河小熊猫
    case panda = "panda"
    
    /// 银河小兔子
    case rabbit = "rabbit"
    
    /// 角色名称
    var displayName: String {
        switch self {
        case .panda:
            return "银河小熊猫"
        case .rabbit:
            return "银河小兔子"
        }
    }
    
    /// 解锁所需的勋章数量
    var unlockThreshold: Int {
        switch self {
        case .panda:
            return GameConstants.pandaUnlockThreshold
        case .rabbit:
            return GameConstants.rabbitUnlockThreshold
        }
    }
}

// MARK: - 支持的语言列表
enum AppLanguage: String, CaseIterable, Codable {
    case chinese = "zh-Hans"      // 中文（简体）
    case traditionalChinese = "zh-Hant"  // 繁体中文
    case english = "en"           // 英文
    case japanese = "ja"          // 日语
    case korean = "ko"            // 韩语
    case spanish = "es"           // 西班牙语
    case portuguese = "pt"        // 葡萄牙语
    
    /// 语言显示名称
    var displayName: String {
        switch self {
        case .chinese:
            return "中文"
        case .traditionalChinese:
            return "繁體中文"
        case .english:
            return "English"
        case .japanese:
            return "日本語"
        case .korean:
            return "한국어"
        case .spanish:
            return "Español"
        case .portuguese:
            return "Português"
        }
    }
}
