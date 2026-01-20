//
//  BadgeCollectionView.swift
//  Mathaxy
//
//  勋章收藏视图
//  展示用户获得的所有勋章和收藏
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
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            VStack(spacing: 0) {
                // 顶部导航
                topBar
                
                // 统计信息
                statisticsView
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                
                // 勋章网格
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(BadgeType.allCases, id: \.self) { badgeType in
                            BadgeCardView(
                                badgeType: badgeType,
                                isEarned: userProfile.badges.contains(where: { $0.type == badgeType }),
                                badge: userProfile.badges.first { $0.type == badgeType }
                            ) {
                                selectedBadge = userProfile.badges.first { $0.type == badgeType }
                                showBadgeDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showBadgeDetail) {
            if let badge = selectedBadge {
                BadgeDetailView(badge: badge)
            }
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        ZStack {
            // 银河背景渐变
            Color.galaxyGradient
                .ignoresSafeArea()
            
            // 星星装饰
            starsView
        }
    }
    
    // MARK: - 星星装饰
    private var starsView: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<25, id: \.self) { index in
                    Circle()
                        .fill(Color.starlightYellow.opacity(Double.random(in: 0.2...0.6)))
                        .frame(width: CGFloat.random(in: 2...4))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
    
    // MARK: - 顶部导航栏
    private var topBar: some View {
        HStack {
            // 关闭按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
            
            Spacer()
            
            // 标题
            Text(LocalizedKeys.myBadges.localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.starlightYellow)
            
            Spacer()
            
            // 收藏按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                // TODO: 显示收藏功能
            }) {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - 统计视图
    private var statisticsView: some View {
        HStack(spacing: 20) {
            // 已获得勋章数
            VStack(spacing: 8) {
                Text("\(userProfile.badges.count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
                
                Text(LocalizedKeys.earned.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.stardustPurple.opacity(0.3))
            )
            
            // 总勋章数
            VStack(spacing: 8) {
                Text("\(BadgeType.allCases.count)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
                
                Text(LocalizedKeys.total.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.stardustPurple.opacity(0.3))
            )
        }
    }
}

// MARK: - 勋章卡片视图
private struct BadgeCardView: View {
    let badgeType: BadgeType
    let isEarned: Bool
    let badge: Badge?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 勋章图标
                ZStack {
                    // 背景圆圈
                    Circle()
                        .fill(isEarned ? Color.starlightYellow.opacity(0.2) : Color.cometWhite.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    // 勋章图标
                    Image(systemName: isEarned ? badgeType.systemImage : "lock.fill")
                        .font(.system(size: 36))
                        .foregroundColor(isEarned ? Color.starlightYellow : Color.cometWhite.opacity(0.5))
                    

                }
                
                // 勋章名称
                Text(badgeType.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isEarned ? Color.cometWhite : Color.cometWhite.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                // 获得日期
                    if isEarned, let badge = badge {
                        Text(DateHelper.shared.formatDate(badge.earnedDate, format: "yyyy-MM-dd"))
                            .font(.system(size: 10))
                            .foregroundColor(Color.cometWhite.opacity(0.6))
                    } else {
                        Text(LocalizedKeys.locked.localized)
                            .font(.system(size: 10))
                            .foregroundColor(Color.cometWhite.opacity(0.4))
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEarned ? Color.stardustPurple.opacity(0.3) : Color.spaceBlue.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEarned ? Color.starlightYellow.opacity(0.5) : Color.cometWhite.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .disabled(!isEarned)
    }
}

// MARK: - 勋章详情视图
private struct BadgeDetailView: View {
    let badge: Badge
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                Color.galaxyGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 勋章大图标
                    ZStack {
                        Circle()
                            .fill(Color.starlightYellow.opacity(0.2))
                            .frame(width: 150, height: 150)
                        
                        Image(systemName: badge.type.systemImage)
                            .font(.system(size: 80))
                            .foregroundColor(Color.starlightYellow)
                    }
                    
                    // 勋章信息
                    VStack(spacing: 20) {
                        // 勋章名称
                        Text(badge.type.displayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.starlightYellow)
                        
                        // 勋章描述
                        Text(badge.type.description)
                            .font(.system(size: 16))
                            .foregroundColor(Color.cometWhite)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        // 获得信息
                        VStack(spacing: 10) {
                            HStack {
                                Text(LocalizedKeys.earned.localized)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.cometWhite.opacity(0.8))
                                
                                Spacer()
                                
                                Text(DateHelper.shared.formatFullDate(badge.earnedDate))
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.starlightYellow)
                            }
                            
                            if let level = badge.level {
                                HStack {
                                    Text(LocalizedKeys.level.localized)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.cometWhite.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    Text("\(level)")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.starlightYellow)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.stardustPurple.opacity(0.3))
                        )
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
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
                            .foregroundColor(Color.cometWhite.opacity(0.8))
                    }
                }
            }
        }
    }
}

// MARK: - 预览
struct BadgeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeCollectionView(userProfile: createMockUserProfile())
            .previewInterfaceOrientation(.portrait)
    }
    
    private static func createMockUserProfile() -> UserProfile {
        var userProfile = UserProfile(nickname: "测试用户")
        userProfile.badges = [
            Badge(type: .levelComplete, level: 1),
            Badge(type: .skipLevel)
        ]
        return userProfile
    }
}