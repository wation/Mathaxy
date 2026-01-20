//
//  AppSettings.swift
//  Mathaxy
//
//  应用设置数据模型
//  管理应用的各项设置
//

import Foundation

// MARK: - 应用设置结构体
struct AppSettings: Codable {
    /// 当前语言
    var language: AppLanguage
    
    /// 是否启用音效
    var isSoundEnabled: Bool
    
    /// 是否启用音乐
    var isMusicEnabled: Bool
    
    /// 是否启用震动反馈
    var isHapticEnabled: Bool
    
    /// 初始化方法
    init(
        language: AppLanguage = .chinese,
        isSoundEnabled: Bool = true,
        isMusicEnabled: Bool = true,
        isHapticEnabled: Bool = true
    ) {
        self.language = language
        self.isSoundEnabled = isSoundEnabled
        self.isMusicEnabled = isMusicEnabled
        self.isHapticEnabled = isHapticEnabled
    }
    
    /// 获取系统语言
    static func getSystemLanguage() -> AppLanguage {
        let systemLanguageCode = Locale.current.language.languageCode?.identifier ?? "en"
        
        // 检查是否支持系统语言
        for supportedLanguage in AppLanguage.allCases {
            if supportedLanguage.rawValue.hasPrefix(systemLanguageCode) {
                return supportedLanguage
            }
        }
        
        // 默认返回中文
        return .chinese
    }
    
    /// 切换语言
    mutating func switchLanguage(to newLanguage: AppLanguage) {
        language = newLanguage
    }
    
    /// 切换音效
    mutating func toggleSound() {
        isSoundEnabled.toggle()
    }
    
    /// 切换音乐
    mutating func toggleMusic() {
        isMusicEnabled.toggle()
    }
    
    /// 切换震动反馈
    mutating func toggleHaptic() {
        isHapticEnabled.toggle()
    }
}

// MARK: - 应用版本信息
struct AppVersionInfo {
    /// 应用版本号
    static let version = "1.0.0"
    
    /// 构建号
    static let build = "1"
    
    /// 获取完整版本信息
    static var fullVersion: String {
        return "v\(version) (Build \(build))"
    }
    
    /// 获取版权信息
    static var copyright: String {
        let year = Calendar.current.component(.year, from: Date())
        return "© \(year) Mathaxy. All rights reserved."
    }
}
