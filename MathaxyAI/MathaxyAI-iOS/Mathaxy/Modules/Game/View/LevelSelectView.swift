//
//  LevelSelectView.swift
//  Mathaxy
//
//  关卡选择视图（新版）
//  - 参考多邻国式“地图路径”体验
//  - 保持现有 Q 版风格：圆润字体、深色背景、柔和阴影
//  - 支持蛇形/之字形路径 + 2.5D 节点（缺资源时自动降级为矢量绘制，保证可编译运行）
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
            QBackground(pageType: .levelSelect) {
                ZStack(alignment: .top) {
                    // 关卡地图（蛇形路径 + 2.5D 节点）
                    QLevelPathMap(
                        nodes: buildNodes(),
                        onTapLevel: { level in
                            // 锁定关卡：沿用原有 ViewModel 逻辑（会提示并播放音效）
                            guard viewModel.isLevelUnlocked(level) else {
                                _ = viewModel.selectLevel(level)
                                return
                            }
                            selectedLevel = level
                            showDetailPopup = true
                        }
                    )
                    .padding(.top, 72) // 给顶部导航留空间

                    // 顶部导航（返回 + 标题）
                    QTopNavBar(
                        title: LocalizedKeys.levelSelect.localized,
                        onBack: { dismiss() }
                    )

                    // 底部信息区（浮层）
                    // 已移除底部进度条、关卡1、开始游戏按钮等内容
                }
                // QBackground 默认会给内容加左右 padding，这里抵消掉，让地图贴边更像“关卡地图”
                .padding(.horizontal, -QSpace.pagePadding)
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
                if let level = selectedLevel, showDetailPopup {
                    QLevelDetailPopup(
                        level: level,
                        config: LevelConfig.getLevelConfig(level),
                        onStart: {
                            viewModel.selectLevel(level)
                            showDetailPopup = false
                        },
                        onClose: { showDetailPopup = false }
                    )
                }
            }
        }
    }

    // MARK: - 构建地图节点数据
    private func buildNodes() -> [QLevelNodeViewData] {
        let total = GameConstants.totalLevels
        return (1...total).map { level in
            let state: QLevelNodeState
            if viewModel.isLevelCompleted(level) {
                state = .completed
            } else if viewModel.isCurrentLevel(level) {
                state = .current
            } else if viewModel.isLevelUnlocked(level) {
                state = .available
            } else {
                state = .locked
            }
            return QLevelNodeViewData(level: level, state: state)
        }
    }
}

// MARK: - 底部信息区（浮层）
private struct QLevelBottomInfoBar: View {

    let progressText: String
    let progress: Double
    let currentLevel: Int
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: QSpace.s) {
            HStack {
                Text(LocalizedKeys.level.localized + " \(currentLevel)")
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onDarkPrimary)

                Spacer(minLength: 0)

                Text(progressText)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }

            QProgressBar(progress: progress, height: 18)

            Button(action: onStart) {
                Text(LocalizedKeys.startGame.localized)
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onLightPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(QColor.brand.accent)
                    .cornerRadius(QRadius.button)
                    .shadow(color: QShadow.elevation1.color, radius: QShadow.elevation1.radius, x: QShadow.elevation1.x, y: QShadow.elevation1.y)
            }
            .buttonStyle(.plain)
        }
        .padding(QSpace.m)
        .background(Color.black.opacity(0.35))
        .cornerRadius(QRadius.card)
        .overlay(
            RoundedRectangle(cornerRadius: QRadius.card)
                .stroke(Color.white.opacity(0.18), lineWidth: QStroke.thin)
        )
        .shadow(color: QShadow.elevation2.color, radius: QShadow.elevation2.radius, x: QShadow.elevation2.x, y: QShadow.elevation2.y)
        .padding(.horizontal, QSpace.pagePadding)
    }
}

#Preview {
    LevelSelectView()
}
