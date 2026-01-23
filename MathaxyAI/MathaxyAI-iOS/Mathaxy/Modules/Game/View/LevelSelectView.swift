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
    
    // MARK: - 导航状态
    @State private var selectedLevel: Int?
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    @State private var hideStatusBar = false
    var body: some View {
        NavigationStack {
            // Q版背景容器：使用 levelSelect 背景图
            QBackground(pageType: .levelSelect) {
                VStack(spacing: 0) {
                    // 页面标题：使用 Q版字体 token
                    Text(LocalizedKeys.levelSelect.localized)
                        .font(QFont.titlePage)
                        .foregroundColor(QColor.text.onDarkPrimary)
                        .padding(.top, QSpace.l)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: QSpace.m) {
                            ForEach(1...GameConstants.totalLevels, id: \.self) { level in
                                // 使用 QLevelButton 组件，状态映射到 QLevelButton.LevelState
                                QLevelButton(
                                    levelNumber: level,
                                    state: mapLevelState(level),
                                    onTap: {
                                        selectedLevel = level
                                    }
                                )
                            }
                        }
                        .padding(QSpace.pagePadding)
                    }
                    
                    Spacer()
                    
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
            .navigationDestination(isPresented: Binding(
                get: { selectedLevel != nil },
                set: { if !$0 { selectedLevel = nil } }
            )) {
                if let level = selectedLevel {
                    GamePlayView(level: level)
                }
            }
        }
    }
    
    // MARK: - 状态映射：将业务状态映射到 QLevelButton.LevelState
    /// 将关卡的业务状态（完成/当前/锁定）映射到 Q 版组件的状态
    /// - Parameter level: 关卡编号
    /// - Returns: QLevelButton.LevelState
    private func mapLevelState(_ level: Int) -> QLevelButton.LevelState {
        let isCompleted = viewModel.userProfile.completedLevels.contains(level)
        let isCurrentLevel = viewModel.userProfile.currentLevel == level
        let isUnlocked = level == 1 || viewModel.userProfile.completedLevels.contains(level - 1)
        
        if isCompleted {
            return .completed
        } else if isCurrentLevel {
            return .current
        } else if isUnlocked {
            return .current // 未解锁但可玩的关卡视为当前状态
        } else {
            return .locked
        }
    }
}

#Preview {
    LevelSelectView()
}
