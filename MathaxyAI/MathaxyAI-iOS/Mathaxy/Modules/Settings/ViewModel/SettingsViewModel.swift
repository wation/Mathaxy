//
//  SettingsViewModel.swift
//  Mathaxy
//
//  设置视图模型
//  管理应用设置和用户偏好
//

import Foundation
import SwiftUI

// MARK: - 设置视图模型
class SettingsViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var appSettings: AppSettings
    @Published var soundEnabled: Bool = true
    @Published var musicEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var currentLanguage: AppLanguage = .chinese
    
    // MARK: - 存储服务
    private let storageService = StorageService.shared
    
    // MARK: - 初始化
    init() {
        // 加载设置
        if let settings = storageService.loadAppSettings() {
            self.appSettings = settings
        } else {
            self.appSettings = AppSettings()
        }
        
        self.soundEnabled = appSettings.isSoundEnabled
        self.musicEnabled = appSettings.isMusicEnabled
        self.vibrationEnabled = appSettings.isHapticEnabled
        self.currentLanguage = appSettings.language
    }
    
    // MARK: - 保存设置
    func saveSettings() {
        appSettings.isSoundEnabled = soundEnabled
        appSettings.isMusicEnabled = musicEnabled
        appSettings.isHapticEnabled = vibrationEnabled
        appSettings.language = currentLanguage
        
        storageService.saveAppSettings(appSettings)
    }
    
    // MARK: - 更改语言
    func changeLanguage(to language: AppLanguage) {
        currentLanguage = language
        appSettings.language = language
        saveSettings()
    }
    
    // MARK: - 切换声音
    func toggleSound() {
        soundEnabled.toggle()
        saveSettings()
    }
    
    // MARK: - 切换音乐
    func toggleMusic() {
        musicEnabled.toggle()
        saveSettings()
    }
    
    // MARK: - 切换振动
    func toggleVibration() {
        vibrationEnabled.toggle()
        saveSettings()
    }
    
    // MARK: - 重置所有设置
    func resetSettings() {
        appSettings = AppSettings()
        soundEnabled = appSettings.isSoundEnabled
        musicEnabled = appSettings.isMusicEnabled
        vibrationEnabled = appSettings.isHapticEnabled
        currentLanguage = appSettings.language
        saveSettings()
    }
    
    // MARK: - 重置所有数据
    func resetAllData() {
        // 调用存储服务清除所有数据
        storageService.clearAllData()
        
        // 重置设置
        resetSettings()
        
        // 发送数据重置通知
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }
}
