//
//  AchievementUnlockPopup.swift
//  Mathaxy
//
//  成就解锁弹窗
//  Q版化：使用 QPopupContainer + QAsset.popup.achievementUnlock + QAsset.component.badgeStyle
//

import SwiftUI

// MARK: - 成就解锁弹窗
/// Q版成就解锁弹窗组件
/// 用于展示用户获得新勋章时的弹窗提示
struct AchievementUnlockPopup: View {
    
    // MARK: - 勋章信息
    let badgeType: BadgeType
    let badge: Badge
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 状态
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 遮罩层：使用 Q 版遮罩色
            QColor.overlay.scrim
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // 弹窗内容：使用 Q 版弹窗容器样式
            VStack(spacing: 0) {
                // 弹窗主体
                popupContent
            }
            .padding(QSpace.l)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
    
    // MARK: - 弹窗内容（Q版样式）
    private var popupContent: some View {
        VStack(spacing: QSpace.l) {
            // 顶部装饰：使用 Q 版成就解锁弹窗背景图
            Image(QAsset.popup.achievementUnlock)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
            
            // 勋章图标：使用 Q 版勋章样式
            ZStack {
                // 背景圆圈
                Circle()
                    .fill(QColor.brand.accent.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                // 勋章图标
                Image(systemName: badgeType.systemImage)
                    .font(.system(size: 60))
                    .foregroundColor(QColor.brand.accent)
            }
            .padding(.top, QSpace.m)
            
            // 勋章名称：使用 Q 版字体 token
            Text(badgeType.displayName)
                .font(QFont.titleSection)
                .foregroundColor(QColor.text.onLightPrimary)
                .multilineTextAlignment(.center)
            
            // 勋章描述
            Text(badgeType.description)
                .font(QFont.body)
                .foregroundColor(QColor.text.onDarkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, QSpace.m)
            
            // 获得信息
            if let relatedLevel = badge.level {
                Text(LocalizedKeys.level.localized + " \(relatedLevel) " + LocalizedKeys.completed.localized)
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.brand.accent)
            }
            
            // 确认按钮：使用 QPrimaryButton
            QPrimaryButton(
                title: LocalizedKeys.ok.localized,
                action: {
                    SoundService.shared.playButtonClickSound()
                    dismiss()
                }
            )
            .padding(.top, QSpace.m)
        }
        .padding(QSpace.xl)
        .qCardStyle() // 使用 Q 版卡片样式
    }
}

// MARK: - 预览
struct AchievementUnlockPopup_Previews: PreviewProvider {
    static var previews: some View {
        let badge = Badge(type: .levelComplete, level: 1)
        return AchievementUnlockPopup(badgeType: .levelComplete, badge: badge)
            .previewInterfaceOrientation(.portrait)
    }
}
