//
//  HomeViewModel.swift
//  Mathaxy
//
//  首页视图模型
//  负责处理首页逻辑
//

import Foundation
import SwiftUI

// MARK: - 首页视图模型
class HomeViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    private let loginTrackingService = LoginTrackingService.shared
    
    // MARK: - 用户资料
    @Published var userProfile: UserProfile
    
    // MARK: - 视图状态
    @Published var showLevelSelect = false
    @Published var showAchievement = false
    @Published var showSettings = false
    
    // MARK: - 初始化
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        // 确保showSettings初始化为false，避免设置页面意外显示
        self.showSettings = false
        self.showAchievement = false
        self.showLevelSelect = false
    }
    
    // MARK: - 导航方法
    
    /// 显示关卡选择
    func showLevelSelectView() {
        SoundService.shared.playButtonClickSound()
        showLevelSelect = true
    }
    
    /// 显示成就页面
    func showAchievementView() {
        SoundService.shared.playButtonClickSound()
        showAchievement = true
    }
    
    /// 显示设置页面
    func showSettingsView() {
        SoundService.shared.playButtonClickSound()
        showSettings = true
    }
    
    // MARK: - 用户资料管理
    
    /// 更新用户资料
    func updateUserProfile() {
        if let updatedProfile = storageService.loadUserProfile() {
            userProfile = updatedProfile
        }
    }
    
    /// 获取当前关卡进度
    func getCurrentLevelProgress() -> String {
        return "\(userProfile.currentLevel)/\(GameConstants.totalLevels)"
    }
    
    /// 获取已解锁角色
    func getUnlockedCharacters() -> [CharacterType] {
        return userProfile.unlockedCharacters
    }
    
    /// 检查是否有新解锁的角色
    func hasNewUnlockedCharacter() -> Bool {
        return userProfile.unlockedCharacters.count > 0
    }
    
    /// 获取最新解锁的角色
    func getLatestUnlockedCharacter() -> CharacterType? {
        return userProfile.unlockedCharacters.last
    }
    
    // MARK: - 登录记录
    
    /// 获取连续登录天数
    func getConsecutiveLoginDays() -> Int {
        return loginTrackingService.consecutiveDays
    }
    
    /// 获取登录进度
    func getLoginProgress() -> Double {
        return loginTrackingService.getLoginProgressPercentage()
    }
    
    /// 获取登录消息
    func getLoginMessage() -> String {
        return loginTrackingService.getLoginMessage()
    }
    
    /// 检查是否已获得坚持小达人勋章
    func hasConsecutiveLoginBadge() -> Bool {
        return loginTrackingService.hasEarnedBadge
    }
    
    // MARK: - 勋章统计
    
    /// 获取总勋章数量
    func getTotalBadgeCount() -> Int {
        return userProfile.totalBadgeCount
    }
    
    /// 获取通关勋章数量
    func getLevelCompleteBadgeCount() -> Int {
        return userProfile.getBadgeCount(for: .levelComplete)
    }
    
    /// 获取跳关勋章数量
    func getSkipLevelBadgeCount() -> Int {
        return userProfile.getBadgeCount(for: .skipLevel)
    }
    
    /// 获取完美勋章数量
    func getPerfectLevelBadgeCount() -> Int {
        return userProfile.getBadgeCount(for: .perfectLevel)
    }
    
    /// 检查是否已通关所有关卡
    func isAllLevelsCompleted() -> Bool {
        return userProfile.isAllLevelsCompleted
    }
    
    /// 检查是否有最新奖状
    func hasLatestCertificate() -> Bool {
        return userProfile.latestCertificate != nil
    }
    
    /// 获取最新奖状
    func getLatestCertificate() -> Certificate? {
        return userProfile.latestCertificate
    }
}
