//
//  BadgeCollectionView.swift
//  Mathaxy
//
//  勋章收藏视图
//  展示用户获得的所有勋章和收藏
//  Q版化：使用 QBackground + QCardStyle + QFont + QSpace + QDecoration
//

import SwiftUI

// MARK: - 勋章收藏视图
struct BadgeCollectionView: View {
    
    // MARK: - 用户资料
    let userProfile: UserProfile
    
    // MARK: - 视图模型
    @StateObject private var viewModel: AchievementViewModel
    
    // MARK: - 初始化
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        _viewModel = StateObject(wrappedValue: AchievementViewModel(userProfile: userProfile))
    }
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 状态
    @State private var selectedBadge: Badge?
    @State private var showBadgeDetail = false
    
    // MARK: - Body
    var body: some View {
        // Q版背景容器：使用 achievement 背景图
        QBackground(pageType: .achievement) {
            // 内容视图
            contentView
        }
        .sheet(isPresented: $showBadgeDetail) {
            badgeDetailSheet
        }
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        VStack(spacing: 0) {
            // 顶部导航
            topBar
            
            // 统计信息（Q版卡片样式）
            statisticsView
                .padding(.horizontal, QSpace.pagePadding)
                .padding(.top, QSpace.l)
            
            // 勋章网格
            badgesGridView
        }
    }
    
    // MARK: - 勋章网格视图
    private var badgesGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: QSpace.l) {
                ForEach(BadgeType.allCases, id: \.self) { badgeType in
                    badgeCardView(for: badgeType)
                }
            }
            .padding(.horizontal, QSpace.pagePadding)
            .padding(.bottom, QSpace.xl)
        }
    }
    
    // MARK: - 勋章卡片视图
    private func badgeCardView(for badgeType: BadgeType) -> some View {
        BadgeCardView(
            badgeType: badgeType,
            isEarned: userProfile.badges.contains(where: { $0.type == badgeType }),
            badge: userProfile.badges.first { $0.type == badgeType }
        ) {
            selectedBadge = userProfile.badges.first { $0.type == badgeType }
            showBadgeDetail = true
        }
    }
    
    // MARK: - 勋章详情弹窗（Q版样式）
    private var badgeDetailSheet: some View {
        Group {
            if let badge = selectedBadge {
                BadgeDetailView(badge: badge)
            } else {
                EmptyView()
            }
        }
    }
    
    // MARK: - 顶部导航栏（Q版样式）
    private var topBar: some View {
        HStack {
            // 关闭按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            
            Spacer()
            
            // 标题：使用 Q 版字体 token
            Text(LocalizedKeys.myBadges.localized)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Spacer()
            
            // 收藏按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                // TODO: 显示收藏功能
            }) {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
        }
        .padding(.horizontal, QSpace.pagePadding)
        .padding(.top, QSpace.s)
    }
    
    // MARK: - 统计视图（Q版卡片样式）
    private var statisticsView: some View {
        HStack(spacing: QSpace.m) {
            // 已获得勋章数
            VStack(spacing: QSpace.s) {
                Text("\(userProfile.badges.count)")
                    .font(QFont.displayHero)
                    .foregroundColor(QColor.brand.accent)
                
                Text(LocalizedKeys.earned.localized)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, QSpace.m)
            .qCardStyle()
            
            // 总勋章数
            VStack(spacing: QSpace.s) {
                Text("\(BadgeType.allCases.count)")
                    .font(QFont.displayHero)
                    .foregroundColor(QColor.brand.accent)
                
                Text(LocalizedKeys.total.localized)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, QSpace.m)
            .qCardStyle()
        }
    }
}

// MARK: - 勋章卡片视图（Q版卡片样式）
private struct BadgeCardView: View {
    let badgeType: BadgeType
    let isEarned: Bool
    let badge: Badge?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: QSpace.m) {
                // 勋章图标（使用 Q 版样式）
                ZStack {
                    // 背景圆圈
                    Circle()
                        .fill(isEarned ? QColor.brand.accent.opacity(0.2) : QColor.text.onDarkSecondary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    // 勋章图标
                    Image(systemName: isEarned ? badgeType.systemImage : "lock.fill")
                        .font(.system(size: 36))
                        .foregroundColor(isEarned ? QColor.brand.accent : QColor.text.onDarkSecondary.opacity(0.5))
                }
                
                // 勋章名称：使用 Q 版字体 token
                Text(badgeType.displayName)
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(isEarned ? QColor.text.onDarkPrimary : QColor.text.onDarkSecondary.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                // 获得日期
                if isEarned, let badge = badge {
                    Text(DateHelper.shared.formatDate(badge.earnedDate, format: "yyyy.MM.dd"))
                        .font(QFont.caption)
                        .foregroundColor(QColor.text.onDarkSecondary)
                } else {
                    Text(LocalizedKeys.locked.localized)
                        .font(QFont.caption)
                        .foregroundColor(QColor.text.onDarkSecondary.opacity(0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, QSpace.l)
            .qCardStyle() // 使用 Q 版卡片样式
        }
        .disabled(!isEarned)
    }
}

// MARK: - 勋章详情视图（Q版样式）
private struct BadgeDetailView: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            // Q版背景容器：使用 achievement 背景图
            QBackground(pageType: .achievement) {
                VStack(spacing: QSpace.xl) {
                    // 勋章大图标
                    ZStack {
                        Circle()
                            .fill(QColor.brand.accent.opacity(0.2))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: badge.type.systemImage)
                            .font(.system(size: 80))
                            .foregroundColor(QColor.brand.accent)
                    }
                    
                    // 勋章信息
                    VStack(spacing: QSpace.l) {
                        // 勋章名称：使用 Q 版字体 token
                        Text(badge.type.displayName)
                            .font(QFont.titleSection)
                            .foregroundColor(QColor.brand.accent)
                        
                        // 勋章描述
                        Text(badge.type.description)
                            .font(QFont.body)
                            .foregroundColor(QColor.text.onDarkPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, QSpace.pagePadding)
                        
                        // 获得信息（Q版卡片样式）
                        VStack(spacing: QSpace.s) {
                            HStack {
                                Text(LocalizedKeys.earnedDate.localized)
                                    .font(QFont.body)
                                    .foregroundColor(QColor.text.onDarkSecondary)
                                
                                Spacer()
                                
                                Text(DateHelper.shared.formatFullDate(badge.earnedDate))
                                    .font(QFont.bodyEmphasis)
                                    .foregroundColor(QColor.brand.accent)
                            }
                            
                            if let relatedLevel = badge.level {
                                HStack {
                                    Text(LocalizedKeys.relatedLevel.localized)
                                        .font(QFont.body)
                                        .foregroundColor(QColor.text.onDarkSecondary)
                                    
                                    Spacer()
                                    
                                    Text(LocalizedKeys.level.localized + " \(relatedLevel)")
                                        .font(QFont.bodyEmphasis)
                                        .foregroundColor(QColor.brand.accent)
                                }
                            }
                        }
                        .padding(.horizontal, QSpace.l)
                        .padding(.vertical, QSpace.m)
                        .qCardStyle()
                    }
                    
                    Spacer()
                }
                .padding(.top, QSpace.xl)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        SoundService.shared.playButtonClickSound()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(QColor.text.onDarkSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - 预览
struct BadgeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        var userProfile = UserProfile(nickname: "测试用户")
        userProfile.badges = [
            Badge(type: .levelComplete, level: 1),
            Badge(type: .skipLevel)
        ]
        
        return BadgeCollectionView(userProfile: userProfile)
            .previewInterfaceOrientation(.portrait)
    }
}