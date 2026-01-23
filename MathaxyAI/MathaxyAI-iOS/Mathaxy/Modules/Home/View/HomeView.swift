//
//  HomeView.swift
//  Mathaxy
//
//  首页 - Q版风格UI版本
//  显示用户信息和主要导航
//  Q版化改造说明：
//  - 背景使用 QBackground(pageType: .home) 替换原渐变+随机星点
//  - 按钮使用 QPrimaryButton 统一样式
//  - 字体、颜色、间距使用 QFont、QColor、QSpace tokens
//  - 装饰使用 QAsset.decoration.star 和 QAsset.character.numberSprite
//  - 勋章展示使用 QAsset.component.badgeStyle
//

import SwiftUI

// MARK: - 首页（Q版风格）
struct HomeView: View {
    
    // MARK: - 用户资料
    let userProfile: UserProfile
    
    // MARK: - 视图模型
    @StateObject private var viewModel: HomeViewModel
    @State private var showGameView = false
    
    // MARK: - 初始化
    init(userProfile: UserProfile) {
        self.userProfile = userProfile
        self._viewModel = StateObject(wrappedValue: HomeViewModel(userProfile: userProfile))
    }
    
    // MARK: - Body
    var body: some View {
        // Q版背景容器：使用 QStyle 首页背景图
        QBackground(pageType: .home) {
            // 内容层
            contentView
        }
        .fullScreenCover(isPresented: $viewModel.showLevelSelect) {
            LevelSelectView(userProfile: userProfile)
        }
        .sheet(isPresented: $viewModel.showAchievement) {
            AchievementView(userProfile: userProfile)
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        VStack(spacing: 0) {
            // 顶部导航
            topNavigationView
            
            Spacer()
            
            // 卡通角色和昵称
            characterView
            
            Spacer()
            
            // 开始游戏按钮 - 使用Q版主按钮样式
            startGameButton
            
            // 关卡进度
            levelProgressView
            
            Spacer()
            
            // 底部导航
            bottomNavigationView
                .padding(.bottom, 40)
        }
    }
    
    // MARK: - 顶部导航视图（Q版风格）
    private var topNavigationView: some View {
        HStack(spacing: 24) {
            // 设置按钮 - 使用Q版星星装饰底（放大2倍 + 横向居中）
            Button(action: {
                viewModel.showSettingsView()
            }) {
                ZStack {
                    // Q版星星装饰作为按钮底座
                    Image(QAsset.decoration.star)
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    // 设置图标
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(QColor.brand.accent)
                }
            }
            
            // 成就按钮 - 使用Q版星星装饰底（放大2倍 + 横向居中）
            Button(action: {
                viewModel.showAchievementView()
            }) {
                ZStack {
                    // Q版星星装饰作为按钮底座
                    Image(QAsset.decoration.star)
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    // 成就图标
                    Image(systemName: "medal.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(QColor.brand.accent)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 20)
    }
    
    // MARK: - 卡通角色视图（Q版风格）
    private var characterView: some View {
        VStack(spacing: QSpace.s) {
            // 卡通角色 - 使用Q版数字精灵
            if let _ = viewModel.getLatestUnlockedCharacter() {
                ZStack {
                    // Q版星星装饰作为角色背景
                    Image(QAsset.decoration.star)
                        .resizable()
                        .frame(width: QSize.avatar, height: QSize.avatar)

                    // 使用Q版数字精灵
                    Image(QAsset.character.numberSprite)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
            } else {
                // 未解锁角色 - 显示锁定状态
                ZStack {
                    // Q版星星装饰作为背景
                    Image(QAsset.decoration.star)
                        .resizable()
                        .frame(width: QSize.avatar, height: QSize.avatar)
                    
                    // 锁定图标
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(QColor.brand.accent.opacity(0.5))
                }
            }
            
            // 昵称 - 使用 Q版标题字体
            Text(userProfile.nickname)
                .font(QFont.nickname)
                .foregroundColor(QColor.text.onDarkPrimary)
        }
        .padding(.top, 40)
    }
    
    // MARK: - 开始游戏按钮视图（Q版风格）
    private var startGameButton: some View {
        // 使用 QPrimaryButton 组件，统一 Q 版按钮样式
        QPrimaryButton(title: LocalizedKeys.startGame.localized) {
            viewModel.showLevelSelectView()
        }
        .padding(.horizontal, QSpace.l)
    }
    
    // MARK: - 关卡进度视图（Q版风格）
    private var levelProgressView: some View {
        VStack(spacing: QSpace.s) {
            // 当前关卡标签 - 使用 Q 版正文字体
            Text(LocalizedKeys.currentLevel.localized)
                .font(QFont.body)
                .foregroundColor(QColor.text.onDarkSecondary)
            
            // 关卡进度数字 - 使用 Q 版大号字体，品牌色强调
            Text(viewModel.getCurrentLevelProgress())
                .font(QFont.displayHero)
                .foregroundColor(QColor.brand.accent)
        }
        .padding(.top, QSpace.xl)
    }
    
    // MARK: - 底部导航视图（Q版风格）
    private var bottomNavigationView: some View {
        HStack(spacing: QSpace.xl) {
            // 只显示勋章数量 - 使用Q版勋章样式底图
            VStack(spacing: QSpace.xs) {
                ZStack {
                    // Q版勋章样式底图
                    Image(QAsset.component.badgeStyle)
                        .resizable()
                        .frame(width: 60, height: 60)
                    
                    // 勋章数量 - 使用 Q 版强调字体
                    Text("\(viewModel.getTotalBadgeCount())")
                        .font(QFont.bodyEmphasis)
                        .foregroundColor(.white)
                }
                
                // 勋章标签 - 使用 Q 版强调字体
                Text(LocalizedKeys.badges.localized)
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
        }
        .padding(.horizontal, QSpace.l)
    }
}

// MARK: - 预览
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let userProfile = UserProfile(nickname: "小银河123")
        HomeView(userProfile: userProfile)
            .previewInterfaceOrientation(.portrait)
    }
}
