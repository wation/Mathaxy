//
//  StorageService.swift
//  Mathaxy
//
//  数据存储服务
//  负责管理用户数据的本地存储（UserDefaults + FileManager）
//

import Foundation
import Combine

// MARK: - 账号信息结构体
struct AccountInfo: Identifiable, Codable {
    let id: UUID
    let nickname: String
    let createdAt: Date
    let lastLoginAt: Date
}

// MARK: - 存储服务类
class StorageService: ObservableObject {
    
    // MARK: - 单例
    static let shared = StorageService()
    
    private init() {}
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let userProfile = "userProfile"
        static let appSettings = "appSettings"
        static let isFirstLaunch = "isFirstLaunch"
        static let lastLaunchDate = "lastLaunchDate"
        static let accountsList = "accountsList"
        static let currentAccountId = "currentAccountId"
    }
    
    // MARK: - 文件管理器
    private let fileManager = FileManager.default
    
    // MARK: - 文档目录
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - 数据文件路径
    private func userProfileFileURL(for accountId: UUID) -> URL {
        return documentsDirectory.appendingPathComponent("userProfile_accountId.uuidString).json")
    }
    
    private var appSettingsFileURL: URL {
        return documentsDirectory.appendingPathComponent("appSettings.json")
    }
    
    // MARK: - 当前账号ID管理
    
    /// 获取当前账号ID
    func getCurrentAccountId() -> UUID? {
        guard let data = UserDefaults.standard.data(forKey: Keys.currentAccountId) else {
            return nil
        }
        return try? JSONDecoder().decode(UUID.self, from: data)
    }
    
    /// 设置当前账号ID
    func setCurrentAccountId(_ accountId: UUID) {
        if let data = try? JSONEncoder().encode(accountId) {
            UserDefaults.standard.set(data, forKey: Keys.currentAccountId)
        }
    }
    
    // MARK: - 账号列表管理
    
    /// 获取账号列表
    func getAccountsList() -> [AccountInfo] {
        guard let data = UserDefaults.standard.data(forKey: Keys.accountsList) else {
            return []
        }
        return (try? JSONDecoder().decode([AccountInfo].self, from: data)) ?? []
    }
    
    /// 保存账号列表
    private func saveAccountsList(_ accounts: [AccountInfo]) {
        if let data = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(data, forKey: Keys.accountsList)
        }
    }
    
    /// 添加新账号到列表
    func addAccount(_ accountInfo: AccountInfo) {
        var accounts = getAccountsList()
        accounts.append(accountInfo)
        saveAccountsList(accounts)
    }
    
    /// 更新账号信息
    func updateAccount(_ updatedAccount: AccountInfo) {
        var accounts = getAccountsList()
        if let index = accounts.firstIndex(where: { $0.id == updatedAccount.id }) {
            accounts[index] = updatedAccount
            saveAccountsList(accounts)
        }
    }
    
    /// 删除账号
    func deleteAccount(_ accountId: UUID) {
        // 删除账号文件
        let fileURL = userProfileFileURL(for: accountId)
        try? fileManager.removeItem(at: fileURL)
        
        // 从列表中移除
        var accounts = getAccountsList()
        accounts.removeAll { $0.id == accountId }
        saveAccountsList(accounts)
        
        // 如果删除的是当前账号，清空当前账号ID
        if getCurrentAccountId() == accountId {
            UserDefaults.standard.removeObject(forKey: Keys.currentAccountId)
        }
    }
    
    /// 更新账号最后登录时间
    func updateAccountLastLogin(at accountId: UUID) {
        var accounts = getAccountsList()
        if let index = accounts.firstIndex(where: { $0.id == accountId }) {
            var updatedAccount = accounts[index]
            let updatedAccountInfo = AccountInfo(
                id: updatedAccount.id,
                nickname: updatedAccount.nickname,
                createdAt: updatedAccount.createdAt,
                lastLoginAt: Date()
            )
            accounts[index] = updatedAccountInfo
            saveAccountsList(accounts)
        }
    }
    
    // MARK: - 用户资料管理
    
    /// 保存用户资料
    func saveUserProfile(_ profile: UserProfile) {
        print("StorageService: Saving user profile for \(profile.nickname) (\(profile.id))")
        
        // 1. 保存到文件
        let fileURL = userProfileFileURL(for: profile.id)
        if let data = try? JSONEncoder().encode(profile) {
            try? data.write(to: fileURL)
        }
        
        // 2. 同时保存到UserDefaults（作为备份，代表当前活跃用户）
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Keys.userProfile)
        }
        
        // 3. 设置为当前账号ID
        setCurrentAccountId(profile.id)
        
        // 4. 更新或添加到账号列表
        var accounts = getAccountsList()
        if let index = accounts.firstIndex(where: { $0.id == profile.id }) {
            // 已存在，更新信息（昵称可能改变，登录时间更新）
            print("StorageService: Updating existing account in list: \(profile.nickname)")
            let existingAccount = accounts[index]
            let updatedAccountInfo = AccountInfo(
                id: existingAccount.id,
                nickname: profile.nickname, // 更新昵称
                createdAt: existingAccount.createdAt, //以此为准
                lastLoginAt: Date() // 更新登录时间
            )
            accounts[index] = updatedAccountInfo
        } else {
            // 不存在，添加新账号
            print("StorageService: Adding new account to list: \(profile.nickname)")
            let accountInfo = AccountInfo(
                id: profile.id,
                nickname: profile.nickname,
                createdAt: Date(), // 新账号创建时间
                lastLoginAt: Date()
            )
            accounts.append(accountInfo)
        }
        saveAccountsList(accounts)
    }
    
    /// 加载用户资料
    func loadUserProfile() -> UserProfile? {
        // 1. 获取当前账号ID
        let currentAccountId = getCurrentAccountId()
        
        // 2. 如果有当前账号ID，尝试从文件加载
        if let accountId = currentAccountId {
            let fileURL = userProfileFileURL(for: accountId)
            if let data = try? Data(contentsOf: fileURL),
               let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
                // 验证ID是否匹配
                if profile.id == accountId {
                    return profile
                }
            }
        }
        
        // 3. 尝试从UserDefaults加载（作为备份）
        if let data = UserDefaults.standard.data(forKey: Keys.userProfile),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            
            // 如果没有当前账号ID（首次启动或重置），使用这个profile
            if currentAccountId == nil {
                addAccountToHistory(profile)
                return profile
            }
            
            // 如果有当前账号ID，必须匹配才能使用
            if profile.id == currentAccountId {
                // 恢复文件
                saveUserProfile(profile)
                return profile
            }
        }
        
        // 4. 如果有当前账号ID但无法加载资料，尝试从账号列表恢复（应对数据丢失）
        if let accountId = currentAccountId {
            let accounts = getAccountsList()
            if let accountInfo = accounts.first(where: { $0.id == accountId }) {
                // 创建新的用户资料，保留昵称和ID
                let recoveredProfile = UserProfile(id: accountId, nickname: accountInfo.nickname)
                saveUserProfile(recoveredProfile)
                return recoveredProfile
            }
        }
        
        return nil
    }
    
    /// 加载指定账号的用户资料
    func loadUserProfile(for accountId: UUID) -> UserProfile? {
        let fileURL = userProfileFileURL(for: accountId)
        if let data = try? Data(contentsOf: fileURL),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }
    
    /// 退出登录（保留账号数据，仅清除当前会话状态）
    func logout() {
        // 清除当前账号ID
        UserDefaults.standard.removeObject(forKey: Keys.currentAccountId)
        // 清除UserDefaults中的活跃用户备份，防止自动登录
        UserDefaults.standard.removeObject(forKey: Keys.userProfile)
    }

    /// 删除用户资料
    func deleteUserProfile() {
        if let currentAccountId = getCurrentAccountId() {
            // 删除当前账号文件
            let fileURL = userProfileFileURL(for: currentAccountId)
            try? fileManager.removeItem(at: fileURL)
            
            // 从账号列表中删除
            deleteAccount(currentAccountId)
        }
        
        // 删除UserDefaults备份
        UserDefaults.standard.removeObject(forKey: Keys.userProfile)
    }
    
    /// 为现有账号添加到历史记录
    private func addAccountToHistory(_ profile: UserProfile) {
        let accounts = getAccountsList()
        if !accounts.contains(where: { $0.id == profile.id }) {
            let accountInfo = AccountInfo(
                id: profile.id,
                nickname: profile.nickname,
                createdAt: profile.loginRecord.lastLoginDate,
                lastLoginAt: profile.loginRecord.lastLoginDate
            )
            addAccount(accountInfo)
            setCurrentAccountId(profile.id)
        }
    }
    
    // MARK: - 应用设置管理
    
    /// 保存应用设置
    func saveAppSettings(_ settings: AppSettings) {
        // 保存到文件
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: appSettingsFileURL)
        }
        
        // 同时保存到UserDefaults（作为备份）
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: Keys.appSettings)
        }
    }
    
    /// 加载应用设置
    func loadAppSettings() -> AppSettings? {
        // 优先从文件加载
        if let data = try? Data(contentsOf: appSettingsFileURL),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return settings
        }
        
        // 如果文件不存在，从UserDefaults加载
        if let data = UserDefaults.standard.data(forKey: Keys.appSettings),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return settings
        }
        
        return nil
    }
    
    /// 删除应用设置
    func deleteAppSettings() {
        // 删除文件
        try? fileManager.removeItem(at: appSettingsFileURL)
        
        // 删除UserDefaults
        UserDefaults.standard.removeObject(forKey: Keys.appSettings)
    }
    
    // MARK: - 首次启动管理
    
    /// 检查是否首次启动
    func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: Keys.isFirstLaunch)
    }
    
    /// 标记已启动
    func markAsLaunched() {
        UserDefaults.standard.set(true, forKey: Keys.isFirstLaunch)
        UserDefaults.standard.set(Date(), forKey: Keys.lastLaunchDate)
    }
    
    /// 获取上次启动日期
    func getLastLaunchDate() -> Date? {
        return UserDefaults.standard.object(forKey: Keys.lastLaunchDate) as? Date
    }
    
    // MARK: - 通用数据存储

    /// 保存自定义数据
    func saveCustomData<T: Codable>(_ data: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    /// 加载自定义数据
    func loadCustomData<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }

    /// 删除自定义数据
    func deleteCustomData(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - 测试兼容方法（用于单元测试）

    /// 保存数据（泛型，测试兼容）
    func save<T: Codable>(_ data: T, forKey key: String) {
        saveCustomData(data, forKey: key)
    }

    /// 加载数据（泛型，测试兼容）
    func load<T: Codable>(forKey key: String) -> T? {
        return loadCustomData(forKey: key, type: T.self)
    }

    /// 删除数据（测试兼容）
    func remove(forKey key: String) {
        deleteCustomData(forKey: key)
    }

    /// 检查数据是否存在（测试兼容）
    func exists(forKey key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    /// 清空所有数据（测试兼容）
    func clearAll() {
        clearAllData()
    }
    
    // MARK: - 清除所有数据
    
    /// 清除所有数据（重置应用）
    func clearAllData() {
        // 删除用户资料
        deleteUserProfile()
        
        // 删除应用设置
        deleteAppSettings()
        
        // 删除首次启动标记
        UserDefaults.standard.removeObject(forKey: Keys.isFirstLaunch)
        UserDefaults.standard.removeObject(forKey: Keys.lastLaunchDate)
        
        // 删除文档目录下的所有文件
        if let files = try? fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    // MARK: - 数据备份与恢复
    
    /// 导出数据（用于备份）
    func exportData() -> Data? {
        let exportData: [String: Any] = [
            "userProfile": loadUserProfile()?.toDictionary() ?? [:],
            "appSettings": loadAppSettings()?.toDictionary() ?? [:],
            "exportDate": Date().timeIntervalSince1970
        ]
        
        return try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
}

// MARK: - Codable扩展（用于数据导出）
extension UserProfile {
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "nickname": nickname,
            "currentLevel": currentLevel,
            "completedLevels": Array(completedLevels),
            "badges": badges.map { $0.toDictionary() },
            "unlockedCharacters": unlockedCharacters.map { $0.rawValue },
            "loginRecord": loginRecord.toDictionary(),
            "certificates": certificates.map { $0.toDictionary() }
        ]
    }
}

extension Badge {
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "type": type.rawValue,
            "level": level ?? 0,
            "earnedDate": earnedDate.timeIntervalSince1970
        ]
    }
}

extension LoginRecord {
    func toDictionary() -> [String: Any] {
        return [
            "lastLoginDate": lastLoginDate.timeIntervalSince1970,
            "consecutiveDays": consecutiveDays,
            "hasEarnedBadge": hasEarnedBadge
        ]
    }
}

extension Certificate {
    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "nickname": nickname,
            "completionDate": completionDate.timeIntervalSince1970,
            "totalTime": totalTime,
            "badgeCount": badgeCount
        ]
    }
}

extension AppSettings {
    func toDictionary() -> [String: Any] {
        return [
            "language": language.rawValue,
            "isSoundEnabled": isSoundEnabled,
            "isMusicEnabled": isMusicEnabled,
            "isHapticEnabled": isHapticEnabled
        ]
    }
}
