//
//  AchievementView.swift
//  Mathaxy
//
//  成就视图
//  显示用户的勋章和成就
//  Q版化：使用 QBackground + QPrimaryButton + QCardStyle
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
        // Q版背景容器：使用 achievement 背景图
        QBackground(pageType: .achievement) {
            VStack(spacing: 0) {
                // 顶部导航栏
                topBar
                
                // 勋章列表
                ScrollView {
                    VStack(spacing: QSpace.m) {
                        ForEach(BadgeType.allCases, id: \.self) { badgeType in
                            BadgeRowView(
                                badgeType: badgeType,
                                isEarned: userProfile.badges.contains(where: { $0.type == badgeType })
                            )
                        }
                    }
                    .padding(.bottom, QSpace.xl)
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏（Q版样式）
    private var topBar: some View {
        HStack {
            // 标题：使用 Q 版字体 token
            Text(LocalizedKeys.achievement.localized)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Spacer()
            
            // 关闭按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
        }
        .padding(.horizontal, QSpace.pagePadding)
        .padding(.top, QSpace.s)
    }
}

// MARK: - 勋章行视图（Q版卡片样式）
private struct BadgeRowView: View {
    let badgeType: BadgeType
    let isEarned: Bool
    
    var body: some View {
        HStack(spacing: QSpace.m) {
            // 勋章图标（使用 Q 版样式）
            ZStack {
                Circle()
                    .fill(isEarned ? QColor.brand.accent.opacity(0.2) : QColor.text.onDarkSecondary.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: isEarned ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(isEarned ? QColor.brand.accent : QColor.text.onDarkSecondary.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: QSpace.xs) {
                Text(badgeType.displayName)
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onDarkPrimary)
                
                Text(badgeType.description)
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            
            Spacer()
            
            // 锁定状态标签
            if !isEarned {
                Text(LocalizedKeys.locked.localized)
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary.opacity(0.6))
            }
        }
        .padding(QSpace.m)
        .qCardStyle() // 使用 Q 版卡片样式
    }
}

#Preview {
    AchievementView(userProfile: UserProfile())
}
