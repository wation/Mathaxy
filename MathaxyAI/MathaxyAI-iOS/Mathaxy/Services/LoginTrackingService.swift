//
//  LoginTrackingService.swift
//  Mathaxy
//
//  登录追踪服务
//  负责追踪用户登录记录和连续登录天数
//

import Foundation

// MARK: - 登录追踪服务类
class LoginTrackingService: ObservableObject {
    
    // MARK: - 单例
    static let shared = LoginTrackingService()
    
    // MARK: - 连续登录天数
    @Published var consecutiveDays: Int = 0

    // MARK: - 是否已获得坚持小达人勋章
    @Published var hasEarnedBadge: Bool = false

    // MARK: - 最后登录日期
    private var lastLoginDate: Date?

    // MARK: - 登录次数（测试兼容）
    private var loginCount: Int = 0

    // MARK: - 登录历史记录（测试兼容）
    private var loginHistory: [Date] = []
    
    private init() {
        loadLoginRecord()
    }
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let lastLoginDate = "lastLoginDate"
        static let consecutiveDays = "consecutiveDays"
        static let hasEarnedBadge = "hasEarnedBadge"
        static let loginCount = "loginCount"
        static let loginHistory = "loginHistory"
    }

    // MARK: - 加载登录记录
    private func loadLoginRecord() {
        if let lastLoginTimestamp = UserDefaults.standard.object(forKey: Keys.lastLoginDate) as? TimeInterval {
            lastLoginDate = Date(timeIntervalSince1970: lastLoginTimestamp)
        }

        consecutiveDays = UserDefaults.standard.integer(forKey: Keys.consecutiveDays)
        hasEarnedBadge = UserDefaults.standard.bool(forKey: Keys.hasEarnedBadge)
        loginCount = UserDefaults.standard.integer(forKey: Keys.loginCount)

        // 加载登录历史
        if let historyData = UserDefaults.standard.data(forKey: Keys.loginHistory),
           let history = try? JSONDecoder().decode([Date].self, from: historyData) {
            loginHistory = history
        }
    }

    // MARK: - 保存登录记录
    private func saveLoginRecord() {
        if let lastLoginDate = lastLoginDate {
            UserDefaults.standard.set(lastLoginDate.timeIntervalSince1970, forKey: Keys.lastLoginDate)
        }
        UserDefaults.standard.set(consecutiveDays, forKey: Keys.consecutiveDays)
        UserDefaults.standard.set(hasEarnedBadge, forKey: Keys.hasEarnedBadge)
        UserDefaults.standard.set(loginCount, forKey: Keys.loginCount)

        // 保存登录历史
        if let historyData = try? JSONEncoder().encode(loginHistory) {
            UserDefaults.standard.set(historyData, forKey: Keys.loginHistory)
        }
    }
    
    // MARK: - 更新登录记录
    /// 更新登录记录并检查是否获得坚持小达人勋章
    /// - Returns: 是否获得了坚持小达人勋章
    @discardableResult
    func updateLoginRecord() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        
        // 首次登录
        guard let lastLogin = lastLoginDate else {
            lastLoginDate = today
            consecutiveDays = 1
            saveLoginRecord()
            return false
        }
        
        let lastLoginDay = Calendar.current.startOfDay(for: lastLogin)
        let daysDifference = Calendar.current.dateComponents([.day], from: lastLoginDay, to: today).day ?? 0
        
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
        
        lastLoginDate = today
        
        // 检查是否达到连续登录7天
        if consecutiveDays >= GameConstants.consecutiveLoginDays && !hasEarnedBadge {
            hasEarnedBadge = true
            
            // 保存登录记录
            saveLoginRecord()
            
            // 返回true表示获得了勋章
            return true
        }
        
        // 保存登录记录
        saveLoginRecord()
        
        return false
    }
    
    // MARK: - 重置登录记录
    func resetLoginRecord() {
        lastLoginDate = nil
        consecutiveDays = 0
        hasEarnedBadge = false
        loginCount = 0
        loginHistory.removeAll()
        saveLoginRecord()
    }
    
    // MARK: - 获取登录记录
    /// 获取登录记录
    /// - Returns: 登录记录
    func getLoginRecord() -> LoginRecord {
        return LoginRecord(
            lastLoginDate: lastLoginDate ?? Date(),
            consecutiveDays: consecutiveDays,
            hasEarnedBadge: hasEarnedBadge
        )
    }
    
    // MARK: - 检查是否需要登录
    /// 检查今天是否已经登录过
    /// - Returns: 是否需要登录
    func needsLogin() -> Bool {
        guard let lastLogin = lastLoginDate else {
            return true
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastLoginDay = Calendar.current.startOfDay(for: lastLogin)
        
        let daysDifference = Calendar.current.dateComponents([.day], from: lastLoginDay, to: today).day ?? 0
        
        return daysDifference > 0
    }
    
    // MARK: - 获取登录进度
    /// 获取登录进度（用于UI显示）
    /// - Returns: 登录进度（0-7）
    func getLoginProgress() -> Int {
        return min(consecutiveDays, GameConstants.consecutiveLoginDays)
    }
    
    /// 获取登录进度百分比
    /// - Returns: 登录进度百分比（0-1）
    func getLoginProgressPercentage() -> Double {
        return Double(consecutiveDays) / Double(GameConstants.consecutiveLoginDays)
    }
    
    /// 获取剩余登录天数
    /// - Returns: 剩余登录天数
    func getRemainingDays() -> Int {
        return max(0, GameConstants.consecutiveLoginDays - consecutiveDays)
    }
    
    // MARK: - 获取登录提示消息
    /// 获取登录提示消息
    /// - Returns: 登录提示消息
    func getLoginMessage() -> String {
        if hasEarnedBadge {
            return LocalizedKeys.consecutiveLogin.localized
        }

        let remainingDays = getRemainingDays()
        if remainingDays > 0 {
            return LocalizedKeys.consecutiveDays.localized(arguments: consecutiveDays, GameConstants.consecutiveLoginDays)
        } else {
            return LocalizedKeys.keepGoing.localized
        }
    }

    // MARK: - 测试兼容方法（用于单元测试）

    /// 记录登录（测试兼容）
    func recordLogin() {
        loginCount += 1
        updateLoginRecord()
        // 添加到历史记录
        loginHistory.append(Date())
        // 限制历史记录为30天
        if loginHistory.count > 30 {
            loginHistory.removeFirst()
        }
    }

    /// 记录指定时间的登录（测试兼容）
    func recordLogin(at date: Date) {
        lastLoginDate = date
        loginCount += 1
        updateLoginRecord()
        // 添加到历史记录
        loginHistory.append(date)
        // 限制历史记录为30天
        if loginHistory.count > 30 {
            loginHistory.removeFirst()
        }
    }

    /// 获取登录次数（测试兼容）
    func getLoginCount() -> Int {
        return loginCount
    }

    /// 获取连续登录天数（测试兼容）
    func getConsecutiveDays() -> Int {
        return consecutiveDays
    }

    /// 获取最后登录时间（测试兼容）
    func getLastLoginTime() -> Date? {
        return lastLoginDate
    }

    /// 检查是否已获得7天连续登录奖励（测试兼容）
    func hasEarnedSevenDayReward() -> Bool {
        return hasEarnedBadge
    }

    /// 标记7天连续登录奖励已领取（测试兼容）
    func markSevenDayRewardClaimed() {
        hasEarnedBadge = false
        saveLoginRecord()
    }

    /// 获取登录历史（测试兼容）
    func getLoginHistory() -> [Date] {
        return loginHistory
    }

    /// 重置登录数据（测试兼容）
    func resetLoginData() {
        resetLoginRecord()
        loginCount = 0
        loginHistory.removeAll()
    }
}

// MARK: - 通知名称扩展
extension Notification.Name {
    static let loginRecordDidUpdate = Notification.Name("loginRecordDidUpdate")
    static let badgeDidEarn = Notification.Name("badgeDidEarn")
}
