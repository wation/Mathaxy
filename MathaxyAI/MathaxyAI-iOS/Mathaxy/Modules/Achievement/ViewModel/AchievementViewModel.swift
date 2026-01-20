//
//  AchievementViewModel.swift
//  Mathaxy
//
//  成就视图模型
//  管理用户勋章和成就数据
//

import Foundation
import SwiftUI

// MARK: - 成就视图模型
class AchievementViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var userProfile: UserProfile
    @Published var earnedBadges: [BadgeType] = []
    @Published var totalBadges: Int = 0
    
    // MARK: - 初始化
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self.totalBadges = GameConstants.totalLevels + 3 // 通关勋章 + 其他勋章
        loadBadges()
    }
    
    // MARK: - 加载勋章
    private func loadBadges() {
        let allBadgeTypes = BadgeType.allCases
        earnedBadges = allBadgeTypes.filter { badgeType in
            userProfile.badges.contains(where: { $0.type == badgeType })
        }
    }
    
    // MARK: - 获取勋章进度
    func getBadgeProgress() -> Double {
        let earned = Double(earnedBadges.count)
        let total = Double(totalBadges)
        return total > 0 ? earned / total : 0
    }
    
    // MARK: - 获取已获得勋章数
    func getEarnedBadgeCount() -> Int {
        return earnedBadges.count
    }
    
    // MARK: - 获取剩余勋章数
    func getRemainingBadgeCount() -> Int {
        return totalBadges - earnedBadges.count
    }
    
    // MARK: - 检查是否已获得特定勋章
    func hasBadge(_ badgeType: BadgeType) -> Bool {
        return userProfile.badges.contains(where: { $0.type == badgeType })
    }
}
