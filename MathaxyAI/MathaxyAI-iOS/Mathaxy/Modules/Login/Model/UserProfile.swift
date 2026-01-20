//
//  UserProfile.swift
//  Mathaxy
//
//  用户数据模型
//  管理用户基本信息和游戏进度
//

import Foundation

// MARK: - 用户资料结构体
struct UserProfile: Identifiable, Codable {
    /// 用户唯一标识
    let id: UUID
    
    /// 用户昵称
    var nickname: String
    
    /// 当前关卡
    var currentLevel: Int
    
    /// 已完成的关卡集合
    var completedLevels: Set<Int>
    
    /// 已获得的勋章列表
    var badges: [Badge]
    
    /// 已解锁的角色列表
    var unlockedCharacters: [CharacterType]
    
    /// 登录记录
    var loginRecord: LoginRecord
    
    /// 奖状列表
    var certificates: [Certificate]
    
    /// 游戏历史
    var gameHistory: [GameSession] = []
    
    /// 总游戏时间
    var totalPlayTime: TimeInterval = 0
    
    /// 初始化方法（游客登录）
    init(nickname: String = "") {
        self.id = UUID()
        self.nickname = nickname.isEmpty ? UserProfile.generateGuestNickname() : nickname
        self.currentLevel = 1
        self.completedLevels = []
        self.badges = []
        self.unlockedCharacters = []
        self.loginRecord = LoginRecord()
        self.certificates = []
    }
    
    /// 生成游客昵称
    static func generateGuestNickname() -> String {
        let randomNum = Int.random(in: 100...999)
        return "小银河\(randomNum)"
    }
    
    /// 更新昵称
    mutating func updateNickname(_ newNickname: String) {
        nickname = newNickname
    }
    
    /// 通关关卡
    mutating func completeLevel(_ level: Int) {
        if !completedLevels.contains(level) {
            completedLevels.insert(level)
        }
        
        // 更新当前关卡
        if level >= currentLevel {
            currentLevel = min(level + 1, GameConstants.totalLevels)
        }
        
        // 检查并解锁角色
        checkCharacterUnlocks()
    }
    
    /// 添加勋章
    mutating func addBadge(_ badge: Badge) {
        // 检查是否已存在相同类型的勋章
        if let index = badges.firstIndex(where: { $0.type == badge.type && $0.level == badge.level }) {
            // 已存在，不重复添加
            return
        }
        
        badges.append(badge)
        
        // 检查并解锁角色
        checkCharacterUnlocks()
    }
    
    /// 检查并解锁角色
    mutating func checkCharacterUnlocks() {
        let totalBadges = badges.count
        
        // 检查小熊猫解锁条件
        if totalBadges >= GameConstants.pandaUnlockThreshold && !unlockedCharacters.contains(.panda) {
            unlockedCharacters.append(.panda)
        }
        
        // 检查小兔子解锁条件
        if totalBadges >= GameConstants.rabbitUnlockThreshold && !unlockedCharacters.contains(.rabbit) {
            unlockedCharacters.append(.rabbit)
        }
    }
    
    /// 添加奖状
    mutating func addCertificate(_ certificate: Certificate) {
        // 检查是否已存在
        if certificates.contains(where: { $0.id == certificate.id }) {
            return
        }
        
        certificates.append(certificate)
    }
    
    /// 获取指定类型的勋章数量
    func getBadgeCount(for type: BadgeType) -> Int {
        return badges.filter { $0.type == type }.count
    }
    
    /// 获取总勋章数量
    var totalBadgeCount: Int {
        return badges.count
    }
    
    /// 是否已通关所有关卡
    var isAllLevelsCompleted: Bool {
        return completedLevels.count >= GameConstants.totalLevels
    }
    
    /// 获取最新奖状
    var latestCertificate: Certificate? {
        return certificates.last
    }
}

// MARK: - 登录记录结构体
struct LoginRecord: Codable {
    /// 最后登录日期
    var lastLoginDate: Date
    
    /// 连续登录天数
    var consecutiveDays: Int
    
    /// 是否已获得坚持小达人勋章
    var hasEarnedBadge: Bool
    
    /// 初始化方法
    init() {
        self.lastLoginDate = Date()
        self.consecutiveDays = 1
        self.hasEarnedBadge = false
    }
    
    /// 自定义初始化方法
    init(lastLoginDate: Date, consecutiveDays: Int, hasEarnedBadge: Bool) {
        self.lastLoginDate = lastLoginDate
        self.consecutiveDays = consecutiveDays
        self.hasEarnedBadge = hasEarnedBadge
    }
    
    /// 更新登录记录
    mutating func updateLoginRecord() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let lastLogin = Calendar.current.startOfDay(for: lastLoginDate)
        
        let daysDifference = Calendar.current.dateComponents([.day], from: lastLogin, to: today).day ?? 0
        
        if daysDifference == 0 {
            // 同一天登录，不更新
            return false
        } else if daysDifference == 1 {
            // 连续登录
            consecutiveDays += 1
        } else {
            // 中断，重新开始
            consecutiveDays = 1
        }
        
        lastLoginDate = Date()
        
        // 检查是否达到连续登录7天
        if consecutiveDays >= GameConstants.consecutiveLoginDays && !hasEarnedBadge {
            hasEarnedBadge = true
            return true  // 返回true表示获得了勋章
        }
        
        return false
    }
}

// MARK: - 勋章结构体
struct Badge: Identifiable, Codable {
    /// 勋章唯一标识
    let id: UUID
    
    /// 勋章类型
    let type: BadgeType
    
    /// 关联关卡（仅加法小勇士、答题小天才）
    let level: Int?
    
    /// 获得日期
    let earnedDate: Date
    
    /// 初始化方法
    init(type: BadgeType, level: Int? = nil) {
        self.id = UUID()
        self.type = type
        self.level = level
        self.earnedDate = Date()
    }
}

// MARK: - 奖状结构体
struct Certificate: Identifiable, Codable {
    /// 奖状唯一标识
    let id: UUID
    
    /// 用户昵称
    let nickname: String
    
    /// 完成日期
    let completionDate: Date
    
    /// 通关总用时（秒）
    let totalTime: Double
    
    /// 获得勋章数量
    let badgeCount: Int
    
    /// 初始化方法
    init(nickname: String, completionDate: Date, totalTime: Double, badgeCount: Int) {
        self.id = UUID()
        self.nickname = nickname
        self.completionDate = completionDate
        self.totalTime = totalTime
        self.badgeCount = badgeCount
    }
    
    /// 格式化总用时
    var formattedTotalTime: String {
        let minutes = Int(totalTime) / 60
        let seconds = Int(totalTime) % 60
        return String(format: "%d分%d秒", minutes, seconds)
    }
}
