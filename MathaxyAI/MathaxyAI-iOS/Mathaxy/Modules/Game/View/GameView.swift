//
//  GameView.swift
//  Mathaxy
//
//  游戏视图
//  显示游戏题目和交互
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
        ZStack {
            // 背景
            Color.spaceBlue
                .ignoresSafeArea()
            
            // 内容
            VStack(spacing: 20) {
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
            .padding(20)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadUserProfile()
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: viewModel.showGameOver) { newValue in
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
    
    // MARK: - 顶部信息栏
    private var topInfoBar: some View {
        HStack {
            // 进度条
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                ProgressView(value: viewModel.getProgress())
                    .tint(Color.starlightYellow)
            }
            
            Spacer()
            
            // 计时器
            VStack(alignment: .trailing, spacing: 4) {
                Text("Time")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Text(String(format: "%.1f s", max(0, viewModel.timeRemaining)))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(viewModel.timeRemaining < 5 ? Color.red : Color.starlightYellow)
            }
        }
    }
    
    // MARK: - 题目卡片
    private func questionCard(_ question: Question) -> some View {
        VStack(spacing: 30) {
            // 题号
            Text("Question \(viewModel.gameSession.currentIndex + 1)/\(viewModel.gameSession.questions.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.cometWhite.opacity(0.8))
            
            // 题目
            HStack(spacing: 20) {
                Text("\(question.addend1)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
                
                Text("+")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.cometWhite)
                
                Text("\(question.addend2)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
                
                Text("=")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.cometWhite)
                
                Text("?")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.stardustPurple)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.stardustPurple.opacity(0.2))
            .cornerRadius(12)
        }
    }
    
    // MARK: - 答案选项
    private var answerOptions: some View {
        VStack(spacing: 12) {
            ForEach([0, 1, 2, 3], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach([0, 1, 2], id: \.self) { col in
                        let index = row * 3 + col
                        if index < 19 {
                            let answer = index
                            Button(action: {
                                viewModel.submitAnswer(answer)
                            }) {
                                Text("\(answer)")
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .foregroundColor(Color.cometWhite)
                                    .background(
                                        viewModel.selectedAnswer == answer ?
                                        Color.starlightYellow :
                                        Color.stardustPurple
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 游戏结束视图
    private var gameOverView: some View {
        VStack(spacing: 20) {
            Text(viewModel.gameSession.isFailed ? "Game Over" : "Congratulations!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(viewModel.gameSession.isFailed ? Color.red : Color.starlightYellow)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Correct:")
                    Spacer()
                    Text("\(viewModel.gameSession.correctCount)")
                }
                
                HStack {
                    Text("Errors:")
                    Spacer()
                    Text("\(viewModel.gameSession.errorCount)")
                }
                
                HStack {
                    Text("Accuracy:")
                    Spacer()
                    Text(String(format: "%.1f%%", viewModel.gameSession.accuracy * 100))
                }
            }
            .foregroundColor(Color.cometWhite)
            .padding(20)
            .background(Color.stardustPurple.opacity(0.2))
            .cornerRadius(12)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Back to Home")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.starlightYellow)
                    .foregroundColor(Color.spaceBlue)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    GameView(level: 1)
}
