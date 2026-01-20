//
//  AchievementView.swift
//  Mathaxy
//
//  成就视图
//  显示用户的勋章和成就
//

import SwiftUI

// MARK: - 成就视图
struct AchievementView: View {
    
    // MARK: - 用户资料
    let userProfile: UserProfile
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color.spaceBlue
                    .ignoresSafeArea()
                
                // 内容
                VStack {
                    HStack {
                        Text(LocalizedKeys.achievement.localized)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.starlightYellow)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.cometWhite)
                        }
                    }
                    .padding(20)
                    
                    // 勋章列表
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(BadgeType.allCases, id: \.self) { badgeType in
                                BadgeRowView(
                                    badgeType: badgeType,
                                    isEarned: userProfile.badges.contains(where: { $0.type == badgeType })
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
    }
}

// MARK: - 勋章行视图
private struct BadgeRowView: View {
    let badgeType: BadgeType
    let isEarned: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: isEarned ? "star.fill" : "star")
                .font(.system(size: 24))
                .foregroundColor(isEarned ? Color.starlightYellow : Color.cometWhite.opacity(0.5))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(badgeType.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.cometWhite)
                
                Text(badgeType.description)
                    .font(.system(size: 12))
                    .foregroundColor(Color.cometWhite.opacity(0.7))
            }
            
            Spacer()
            
            if !isEarned {
                Text(LocalizedKeys.locked.localized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.5))
            }
        }
        .padding(12)
        .background(isEarned ? Color.stardustPurple.opacity(0.3) : Color.spaceBlue.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    AchievementView(userProfile: UserProfile())
}
