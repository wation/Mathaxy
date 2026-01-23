//
//  GamePlayView.swift
//  Mathaxy
//
//  游戏玩法视图
//  显示实际的游戏界面和交互
//  Q版化：使用 QBackground + QTimerBadge + QProgressBar + QAnswerOptionButton + QPopupContainer
//

import SwiftUI

// MARK: - 游戏玩法视图
struct GamePlayView: View {
    
    // MARK: - 视图模型
    @StateObject private var viewModel: GamePlayViewModel
    @State private var showExitAlert = false
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 初始化
    init(level: Int) {
        self._viewModel = StateObject(wrappedValue: GamePlayViewModel(level: level))
    }
    
    // MARK: - Body
    @State private var hideStatusBar = false
    var body: some View {
        // Q版背景容器：使用 game 背景图
        QBackground(pageType: .game) {
            VStack(spacing: 0) {
                // 顶部信息栏
                topInfoBar
                    .padding(.horizontal, QSpace.pagePadding)
                    .padding(.top, QSpace.s)
                
                // 调整计算框位置，减小顶部间距
                Spacer().frame(height: QSpace.s)
                
                if let question = viewModel.currentQuestion {
                    questionArea(question: question)
                } else {
                    loadingView
                }
                
                Spacer()
                
                // Q版进度条：使用 QProgressBar 组件
                if !viewModel.isGameCompleted {
                    QProgressBar(progress: viewModel.progress, height: 24)
                        .padding(.horizontal, QSpace.xl)
                }
                
                Spacer()
                
                if !viewModel.isGameCompleted {
                    answerGrid
                        .padding(.horizontal, QSpace.pagePadding)
                        .padding(.bottom, QSpace.l)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .overlay(
            // Q版结果反馈覆盖层
            viewModel.showResult ? resultOverlay : nil
        )
        .overlay(
            // Q版退出确认弹窗
            showExitAlert ? exitAlertPopup : nil
        )
        .statusBar(hidden: hideStatusBar)
        .onAppear { hideStatusBar = true; viewModel.startGame() }
        .onDisappear { hideStatusBar = false; viewModel.pauseGame() }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $viewModel.showGameComplete) {
            if let gameSession = viewModel.gameSession {
                ResultView(gameSession: gameSession)
                    .onDisappear {
                        dismiss()
                    }
            }
        }
    }
    
    // MARK: - 顶部信息栏
    private var topInfoBar: some View {
        ZStack {
            // 左侧：返回按钮
            HStack {
                Button(action: {
                    SoundService.shared.playButtonClickSound()
                    showExitAlert = true
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(QColor.text.onDarkPrimary)
                }
                Spacer()
            }
            
            // 中间：关卡信息 (绝对居中)
            VStack(spacing: QSpace.xs) {
                Text(LocalizedKeys.level.localized + " \(viewModel.level)")
                    .font(QFont.titlePage)
                    .foregroundColor(QColor.text.onDarkPrimary)
                
                Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.totalQuestions)")
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            .frame(maxWidth: .infinity)
            
            // 右侧：Q版计时器徽章
            HStack {
                Spacer()
                VStack(spacing: QSpace.xs) {
                    Text(LocalizedKeys.time.localized)
                        .font(QFont.caption)
                        .foregroundColor(QColor.text.onDarkPrimary)
                    
                    // 对于第7-10关需要显示到0.1s精度
                    let config = LevelConfig.getLevelConfig(viewModel.level)
                    let remainingTime = Int(viewModel.timeRemaining)
                    
                    // 使用 Q版计时器徽章组件
                    QTimerBadge(
                        remainingTime: remainingTime,
                        totalTime: Int(config.timeLimit)
                    )
                }
            }
        }
        .padding(.vertical, QSpace.s)
    }
    
    // MARK: - 题目区域（Q版卡片样式）
    private func questionArea(question: Question) -> some View {
        // 题目表达式
        HStack(spacing: QSpace.l) {
            Text("\(question.addend1)")
                .font(QFont.game.questionNumber)
                .foregroundColor(QColor.brand.accent)
            
            Text("+")
                .font(QFont.game.mathOperator)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Text("\(question.addend2)")
                .font(QFont.game.questionNumber)
                .foregroundColor(QColor.brand.accent)
            
            Text("=")
                .font(QFont.game.mathOperator)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            // 显示用户输入的数字，如果没有输入则显示问号
            Text(viewModel.userInputAnswer.isEmpty ? "?" : viewModel.userInputAnswer)
                .font(QFont.game.questionNumber)
                .foregroundColor(
                    viewModel.hasInputError ? QColor.state.danger :
                    (viewModel.userInputAnswer.isEmpty ? QColor.text.onDarkSecondary : QColor.brand.accent)
                )
                .frame(minWidth: 80)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, QSpace.l)
        .padding(.horizontal, QSpace.m)
        .qCardStyle() // 使用 Q 版卡片样式
        .padding(.horizontal, QSpace.m)
    }
    
    // MARK: - 加载视图
    private var loadingView: some View {
        VStack(spacing: QSpace.m) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: QColor.brand.accent))
                .scaleEffect(1.5)
            
            Text(LocalizedKeys.loading.localized)
                .font(QFont.body)
                .foregroundColor(QColor.text.onDarkSecondary)
        }
    }
    
    // MARK: - 答案网格（使用 QAnswerOptionButton）
    private var answerGrid: some View {
        Grid(horizontalSpacing: QSpace.s, verticalSpacing: QSpace.s) {
            GridRow {
                ForEach(7...9, id: \.self) { number in
                    QAnswerOptionButton(
                        value: "\(number)",
                        state: .normal,
                        onTap: {
                            viewModel.playButtonClickSound()
                            viewModel.inputDigit(number)
                        }
                    )
                }
            }
            GridRow {
                ForEach(4...6, id: \.self) { number in
                    QAnswerOptionButton(
                        value: "\(number)",
                        state: .normal,
                        onTap: {
                            viewModel.playButtonClickSound()
                            viewModel.inputDigit(number)
                        }
                    )
                }
            }
            GridRow {
                ForEach(1...3, id: \.self) { number in
                    QAnswerOptionButton(
                        value: "\(number)",
                        state: .normal,
                        onTap: {
                            viewModel.playButtonClickSound()
                            viewModel.inputDigit(number)
                        }
                    )
                }
            }
            GridRow {
                // 清空按钮（使用 Q 版样式）
                QClearButton {
                    viewModel.playButtonClickSound()
                    viewModel.clearAllInput()
                }
                QAnswerOptionButton(
                    value: "0",
                    state: .normal,
                    onTap: {
                        viewModel.playButtonClickSound()
                        viewModel.inputDigit(0)
                    }
                )
                QClearButton {
                    viewModel.playButtonClickSound()
                    viewModel.clearAllInput()
                }
            }
        }
    }
    
    // MARK: - Q版结果反馈覆盖层
    /// 包含轻量动画：弹跳/抖动/淡入淡出
    /// 触发时机沿用原逻辑（由 ViewModel 控制 showResult）
    private var resultOverlay: some View {
        ZStack {
            QColor.overlay.scrim
                .ignoresSafeArea()
            
            VStack(spacing: QSpace.xl) {
                // Q版结果反馈图标（带弹跳动画）
                HStack {
                    Spacer()
                    Image(viewModel.isCorrectAnswer ? QAsset.feedback.correct : QAsset.feedback.incorrect)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 240) // 图标放大2倍，横向居中
                        .modifier(QFeedbackAnimation(isCorrect: viewModel.isCorrectAnswer))
                    Spacer()
                }
                
                // 结果文本（带淡入动画）
                Text(viewModel.isCorrectAnswer ? LocalizedKeys.correct.localized : LocalizedKeys.incorrect.localized)
                    .font(QFont.displayHero)
                    .foregroundColor(QColor.text.onDarkPrimary)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                
                // 正确答案（带淡入动画）
                if !viewModel.isCorrectAnswer, let question = viewModel.currentQuestion {
                    Text(LocalizedKeys.correctAnswer.localized + ": \(question.correctAnswer)")
                        .font(QFont.body)
                        .foregroundColor(QColor.brand.accent)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .padding(QSpace.xl)
            .qCardStyle() // 使用 Q 版卡片样式
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .scale(scale: 0.8).combined(with: .opacity)
            ))
        }
    }
    
    // MARK: - Q版退出确认弹窗
    private var exitAlertPopup: some View {
        QPopupContainer(
            title: LocalizedKeys.exitGame.localized,
            content: {
                VStack(spacing: QSpace.s) {
                    Text(LocalizedKeys.exitWarning.localized)
                        .font(QFont.body)
                        .foregroundColor(QColor.text.onLightPrimary)
                        .multilineTextAlignment(.center)
                }
            },
            primaryButtonTitle: LocalizedKeys.exit.localized,
            secondaryButtonTitle: LocalizedKeys.cancel.localized,
            onPrimary: { dismiss() },
            onSecondary: { showExitAlert = false }
        )
        .onAppear {
            SoundService.shared.playButtonClickSound()
        }
    }
}

// MARK: - Q版清空按钮
/// Q版清空按钮组件
/// 使用 Q 版样式，与 QAnswerOptionButton 保持视觉一致
private struct QClearButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("清空")
                .font(QFont.bodyEmphasis)
                .foregroundColor(QColor.state.danger)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: QRadius.button)
                        .fill(Color.white.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: QRadius.button)
                                .stroke(QColor.state.danger, lineWidth: QStroke.medium)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - QFeedbackAnimation（反馈动画 ViewModifier）
/// Q版反馈动画 ViewModifier
/// 用于正确/错误反馈的弹跳/抖动动画
/// 轻量实现，不影响布局
private struct QFeedbackAnimation: ViewModifier {
    let isCorrect: Bool
    @State private var scale: CGFloat = 0.0
    @State private var rotation: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                // 淡入 + 弹跳动画
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                // 错误答案时添加轻微抖动效果
                if !isCorrect {
                    withAnimation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true)) {
                        rotation = 5.0
                    }
                    // 恢复旋转
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            rotation = 0.0
                        }
                    }
                }
            }
    }
}

// MARK: - 预览
struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        GamePlayView(level: 1)
            .previewInterfaceOrientation(.portrait)
    }
}