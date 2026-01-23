//
//  GameView.swift
//  Mathaxy
//
//  游戏视图（备用实现）
//  显示游戏题目和交互
//  Q版化：使用 QBackground + QProgressBar + QCardStyle
//

import SwiftUI

// MARK: - 游戏视图
struct GameView: View {
    
    // MARK: - 视图模型
    @StateObject private var viewModel: GameViewModel
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storageService: StorageService
    
    // MARK: - 状态
    @State private var userProfile: UserProfile?
    
    // MARK: - 初始化
    init(level: Int) {
        self._viewModel = StateObject(wrappedValue: GameViewModel(level: level))
    }
    
    // MARK: - Body
    var body: some View {
        // Q版背景容器：使用 game 背景图
        QBackground(pageType: .game) {
            VStack(spacing: QSpace.m) {
                // 顶部信息栏
                topInfoBar
                
                // 题目显示
                if let question = viewModel.getCurrentQuestion() {
                    questionCard(question)
                } else {
                    gameOverView
                }
                
                Spacer()
                
                // 答案选项
                if !viewModel.gameSession.isCompleted {
                    answerOptions
                }
            }
            .padding(QSpace.pagePadding)
        }
        .onAppear {
            loadUserProfile()
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: viewModel.showGameOver) { _, newValue in
            if newValue {
                // 重新加载用户资料以获取最新数据
                userProfile = storageService.loadUserProfile()
                // 游戏结束，通知父视图刷新
                NotificationCenter.default.post(name: .gameDidComplete, object: nil)
            }
        }
    }
    
    // MARK: - 加载用户资料
    private func loadUserProfile() {
        userProfile = storageService.loadUserProfile()
    }
    
    // MARK: - 顶部信息栏（Q版样式）
    private var topInfoBar: some View {
        HStack {
            // Q版进度条
            VStack(alignment: .leading, spacing: QSpace.xs) {
                Text("Progress")
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                QProgressBar(progress: viewModel.getProgress(), height: 12)
            }
            
            Spacer()
            
            // 计时器
            VStack(alignment: .trailing, spacing: QSpace.xs) {
                Text("Time")
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                let remainingTime = Int(viewModel.timeRemaining)
                Text("\(remainingTime) s")
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(viewModel.timeRemaining < 5 ? QColor.state.danger : QColor.brand.accent)
            }
        }
    }
    
    // MARK: - 题目卡片（Q版卡片样式）
    private func questionCard(_ question: Question) -> some View {
        VStack(spacing: QSpace.l) {
            // 题号
            Text("Question \(viewModel.gameSession.currentIndex + 1)/\(viewModel.gameSession.questions.count)")
                .font(QFont.caption)
                .foregroundColor(QColor.text.onDarkSecondary)
            
            // 题目
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
                
                Text("?")
                    .font(QFont.game.questionNumber)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(QSpace.m)
        }
        .qCardStyle() // 使用 Q 版卡片样式
    }
    
    // MARK: - 答案选项（Q版样式）
    private var answerOptions: some View {
        VStack(spacing: QSpace.s) {
            ForEach([0, 1, 2, 3], id: \.self) { row in
                HStack(spacing: QSpace.s) {
                    ForEach([0, 1, 2], id: \.self) { col in
                        let index = row * 3 + col
                        if index < 19 {
                            let answer = index
                            Button(action: {
                                viewModel.submitAnswer(answer)
                            }) {
                                Text("\(answer)")
                                    .font(QFont.bodyEmphasis)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundColor(QColor.text.onDarkPrimary)
                                    .background(
                                        viewModel.selectedAnswer == answer ?
                                        QColor.brand.accent :
                                        Color.white.opacity(0.2)
                                    )
                                    .cornerRadius(QRadius.button)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 游戏结束视图（Q版样式）
    private var gameOverView: some View {
        VStack(spacing: QSpace.m) {
            Text(viewModel.gameSession.isFailed ? "Game Over" : "Congratulations!")
                .font(QFont.displayHero)
                .foregroundColor(viewModel.gameSession.isFailed ? QColor.state.danger : QColor.brand.accent)
            
            VStack(spacing: QSpace.s) {
                HStack {
                    Text("Correct:")
                        .foregroundColor(QColor.text.onDarkSecondary)
                    Spacer()
                    Text("\(viewModel.gameSession.correctCount)")
                        .foregroundColor(QColor.brand.accent)
                }
                
                HStack {
                    Text("Errors:")
                        .foregroundColor(QColor.text.onDarkSecondary)
                    Spacer()
                    Text("\(viewModel.gameSession.errorCount)")
                        .foregroundColor(QColor.state.danger)
                }
                
                HStack {
                    Text("Accuracy:")
                        .foregroundColor(QColor.text.onDarkSecondary)
                    Spacer()
                    Text(String(format: "%.1f%%", viewModel.gameSession.accuracy * 100))
                        .foregroundColor(QColor.brand.accent)
                }
            }
            .padding(QSpace.m)
            .qCardStyle() // 使用 Q 版卡片样式
            
            Spacer()
            
            // 返回按钮：使用 QPrimaryButton
            QPrimaryButton(
                title: "Back to Home",
                action: { dismiss() }
            )
        }
    }
}

#Preview {
    GameView(level: 1)
}
