//
//  LevelSelectView.swift
//  Mathaxy
//
//  关卡选择视图
//  显示可用关卡和用户进度
//  Q版化：使用 QBackground + QLevelButton + QSecondaryButton
//

import SwiftUI

// MARK: - 关卡选择视图
struct LevelSelectView: View {
    
    @StateObject private var viewModel: LevelSelectViewModel
    
    // MARK: - 初始化
    init(userProfile: UserProfile? = nil) {
        _viewModel = StateObject(wrappedValue: LevelSelectViewModel(userProfile: userProfile))
    }
    
    // MARK: - 状态管理
    @State private var selectedLevel: Int?
    @State private var showDetailPopup = false
    @State private var hideStatusBar = false
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            // Q版背景容器：使用 levelSelect 背景图
            QBackground(pageType: .levelSelect) {
                VStack(spacing: QSpace.m) {
                    // 页面标题：使用 Q版字体 token
                    Text(LocalizedKeys.levelSelect.localized)
                        .font(QFont.titlePage)
                        .foregroundColor(QColor.text.onDarkPrimary)
                        .padding(.top, QSpace.l)
                    
                    // 调试信息：关卡数量和当前关卡
                    Text("总关卡数: \(GameConstants.totalLevels)")
                        .font(QFont.body)
                        .foregroundColor(QColor.text.onDarkPrimary)
                    
                    Text("当前关卡: \(viewModel.userProfile.currentLevel)")
                        .font(QFont.body)
                        .foregroundColor(QColor.text.onDarkPrimary)
                    
                    Text("已完成关卡: \(viewModel.userProfile.completedLevels.count)")
                        .font(QFont.body)
                        .foregroundColor(QColor.text.onDarkPrimary)
                    
                    // 路径式关卡布局
                    QLevelPath(
                        totalLevels: GameConstants.totalLevels,
                        currentLevel: viewModel.userProfile.currentLevel,
                        completedLevels: viewModel.userProfile.completedLevels,
                        onLevelTap: {
                            if viewModel.isLevelUnlocked($0) {
                                selectedLevel = $0
                                showDetailPopup = true
                            }
                        }
                    )
                    .frame(maxHeight: .infinity)
                    .background(Color.black.opacity(0.1)) // 添加背景色，方便调试
                    
                    // 返回按钮：使用 QSecondaryButton 组件
                    QSecondaryButton(
                        title: LocalizedKeys.back.localized,
                        action: { dismiss() }
                    )
                    .padding(.horizontal, QSpace.pagePadding)
                    .padding(.bottom, QSpace.l)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .statusBar(hidden: hideStatusBar)
            .onAppear { hideStatusBar = true }
            .onDisappear { hideStatusBar = false }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $showDetailPopup) {
                if let level = selectedLevel {
                    GamePlayView(level: level)
                }
            }
            .overlay {
                // 关卡详情弹窗
                if let level = selectedLevel, showDetailPopup {
                    QLevelDetailPopup(
                        level: level,
                        config: LevelConfig.getLevelConfig(level),
                        onStart: {
                            // 选择关卡并开始游戏
                            viewModel.selectLevel(level)
                            showDetailPopup = false
                        },
                        onClose: {
                            showDetailPopup = false
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    LevelSelectView()
}
