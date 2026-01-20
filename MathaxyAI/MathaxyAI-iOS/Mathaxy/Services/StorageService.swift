//
//  StorageService.swift
//  Mathaxy
//
//  数据存储服务
//  负责管理用户数据的本地存储（UserDefaults + FileManager）
//

import Foundation
import Combine

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
    }
    
    // MARK: - 文件管理器
    private let fileManager = FileManager.default
    
    // MARK: - 文档目录
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - 数据文件路径
    private var userProfileFileURL: URL {
        return documentsDirectory.appendingPathComponent("userProfile.json")
    }
    
    private var appSettingsFileURL: URL {
        return documentsDirectory.appendingPathComponent("appSettings.json")
    }
    
    // MARK: - 用户资料管理
    
    /// 保存用户资料
    func saveUserProfile(_ profile: UserProfile) {
        // 保存到文件
        if let data = try? JSONEncoder().encode(profile) {
            try? data.write(to: userProfileFileURL)
        }
        
        // 同时保存到UserDefaults（作为备份）
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Keys.userProfile)
        }
    }
    
    /// 加载用户资料
    func loadUserProfile() -> UserProfile? {
        // 优先从文件加载
        if let data = try? Data(contentsOf: userProfileFileURL),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        
        // 如果文件不存在，从UserDefaults加载
        if let data = UserDefaults.standard.data(forKey: Keys.userProfile),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        
        return nil
    }
    
    /// 删除用户资料
    func deleteUserProfile() {
        // 删除文件
        try? fileManager.removeItem(at: userProfileFileURL)
        
        // 删除UserDefaults
        UserDefaults.standard.removeObject(forKey: Keys.userProfile)
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
