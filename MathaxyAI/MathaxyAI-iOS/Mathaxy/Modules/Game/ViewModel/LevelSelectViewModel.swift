//
//  LevelSelectViewModel.swift
//  Mathaxy
//
//  关卡选择视图模型
//  管理关卡选择逻辑和状态
//

import Foundation
import SwiftUI

// MARK: - 关卡选择视图模型
class LevelSelectViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    
    // MARK: - 发布属性
    @Published var userProfile: UserProfile
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // MARK: - 初始化
    init(userProfile: UserProfile? = nil) {
        if let profile = userProfile {
            self.userProfile = profile
        } else {
            self.userProfile = UserProfile()
        }
        
        // Observe profile updates so UI refreshes when a level is completed
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserProfile), name: .userProfileUpdated, object: nil)
        loadUserProfile()
    }
    
    // MARK: - 加载用户资料
    @objc func loadUserProfile() {
        isLoading = true
        
        if let profile = storageService.loadUserProfile() {
            userProfile = profile
            showError = false
        } else {
            showError = true
            errorMessage = "加载用户资料失败"
        }
        
        isLoading = false
    }
    
    // MARK: - 检查关卡是否解锁
    func isLevelUnlocked(_ level: Int) -> Bool {
        // 第一关总是解锁的
        if level == 1 {
            return true
        }
        
        // 检查前一关是否完成
        let previousLevel = level - 1
        return userProfile.completedLevels.contains(previousLevel)
    }
    
    // MARK: - 检查关卡是否完成
    func isLevelCompleted(_ level: Int) -> Bool {
        return userProfile.completedLevels.contains(level)
    }
    
    // MARK: - 检查是否为当前关卡
    func isCurrentLevel(_ level: Int) -> Bool {
        return userProfile.currentLevel == level
    }
    
    // MARK: - 获取关卡进度
    func getLevelProgress() -> String {
        let completedCount = userProfile.completedLevels.count
        let totalLevels = GameConstants.totalLevels
        
        return "\(completedCount)/\(totalLevels)"
    }
    
    // MARK: - 获取完成进度百分比
    func getProgressPercentage() -> Double {
        let completedCount = userProfile.completedLevels.count
        let totalLevels = GameConstants.totalLevels
        
        return Double(completedCount) / Double(totalLevels)
    }
    
    // MARK: - 选择关卡
    func selectLevel(_ level: Int) -> Bool {
        // 检查关卡是否解锁
        guard isLevelUnlocked(level) else {
            SoundService.shared.playErrorSound()
            showError = true
            errorMessage = "该关卡尚未解锁"
            return false
        }
        
        // 播放音效
        SoundService.shared.playButtonClickSound()
        
        // 更新当前关卡
        userProfile.currentLevel = level
        saveUserProfile()
        
        return true
    }
    
    // MARK: - 保存用户资料
    private func saveUserProfile() {
        storageService.saveUserProfile(userProfile)
    }
    
    // MARK: - 重置进度
    func resetProgress() {
        // 确认对话框应该在视图中处理
        userProfile.completedLevels.removeAll()
        userProfile.currentLevel = 1
        userProfile.badges.removeAll()
        userProfile.certificates.removeAll()
        
        saveUserProfile()
        SoundService.shared.playSuccessSound()
    }
    
    // MARK: - 解锁所有关卡（调试用）
    func unlockAllLevels() {
        // 仅用于调试
        #if DEBUG
        userProfile.completedLevels = Set(1...GameConstants.totalLevels)
        userProfile.currentLevel = GameConstants.totalLevels
        saveUserProfile()
        #endif
    }
    
    // MARK: - 获取关卡难度描述
    func getLevelDifficultyDescription(_ level: Int) -> String {
        let config = LevelConfig.getLevelConfig(level)
        return config.description
    }
    
    // MARK: - 获取关卡星星数
    func getLevelStars(_ level: Int) -> Int {
        // TODO: 根据关卡完成情况返回星星数
        // 1星：通过
        // 2星：正确率 > 80%
        // 3星：正确率 > 95%
        
        guard isLevelCompleted(level) else {
            return 0
        }
        
        // 暂时返回默认值，实际应该从游戏记录中获取
        return 1
    }
    
    // MARK: - 清除错误
    func clearError() {
        errorMessage = ""
        showError = false
    }
}