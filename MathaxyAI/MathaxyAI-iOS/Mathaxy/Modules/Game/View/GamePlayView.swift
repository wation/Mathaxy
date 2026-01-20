//
//  GamePlayView.swift
//  Mathaxy
//
//  游戏玩法视图
//  显示实际的游戏界面和交互
//

import SwiftUI

// MARK: - 游戏玩法视图
struct GamePlayView: View {
    
    // MARK: - 视图模型
    @StateObject private var viewModel: GamePlayViewModel
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 初始化
    init(level: Int) {
        self._viewModel = StateObject(wrappedValue: GamePlayViewModel(level: level))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            VStack(spacing: 0) {
                // 顶部信息栏
                topInfoBar
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                Spacer()
                
                // 题目显示区域
                if let question = viewModel.currentQuestion {
                    questionArea(question: question)
                } else {
                    loadingView
                }
                
                Spacer()
                
                // 答案选择区域
                if !viewModel.isGameCompleted {
                    answerGrid
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            
            // 结果覆盖层
            if viewModel.showResult {
                resultOverlay
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .onDisappear {
            viewModel.pauseGame()
        }
        .sheet(isPresented: $viewModel.showGameComplete) {
            ResultView(gameSession: viewModel.gameSession)
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
                ForEach(0..<20, id: \.self) { index in
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
    
    // MARK: - 顶部信息栏
    private var topInfoBar: some View {
        HStack {
            // 返回按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(Color.starlightYellow)
            }
            
            Spacer()
            
            // 关卡信息
            VStack(spacing: 4) {
                Text(LocalizedKeys.level.localized + " \(viewModel.level)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.totalQuestions)")
                    .font(.system(size: 14))
                    .foregroundColor(Color.cometWhite.opacity(0.6))
            }
            
            Spacer()
            
            // 计时器
            VStack(spacing: 4) {
                Text(LocalizedKeys.time.localized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Text(String(format: "%.0f", viewModel.timeRemaining))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(viewModel.timeRemaining < 10 ? Color.alertRed : Color.starlightYellow)
            }
        }
    }
    
    // MARK: - 题目区域
    private func questionArea(question: Question) -> some View {
        VStack(spacing: 30) {
            // 题目卡片
            VStack(spacing: 20) {
                // 题目表达式
                HStack(spacing: 20) {
                    Text("\(question.addend1)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(Color.starlightYellow)
                    
                    Text("+")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color.cometWhite)
                    
                    Text("\(question.addend2)")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(Color.starlightYellow)
                    
                    Text("=")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(Color.cometWhite)
                    
                    // 显示用户输入的数字，如果没有输入则显示问号
                    Text(viewModel.userInputAnswer.isEmpty ? "?" : viewModel.userInputAnswer)
                        .font(.system(size: 56, weight: .bold))
                        .foregroundColor(viewModel.userInputAnswer.isEmpty ? Color.stardustPurple : Color.starlightYellow)
                        .frame(minWidth: 80)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.stardustPurple.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.starlightYellow, lineWidth: 2)
                        )
                )
                
                // 进度条
                ProgressView(value: viewModel.progress)
                    .tint(Color.starlightYellow)
                    .scaleEffect(y: 2)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - 加载视图
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.starlightYellow))
                .scaleEffect(1.5)
            
            Text(LocalizedKeys.loading.localized)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.cometWhite.opacity(0.8))
        }
    }
    
    // MARK: - 答案网格
    private var answerGrid: some View {
        Grid(horizontalSpacing: 12, verticalSpacing: 12) {
            GridRow {
                ForEach(7...9, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.inputDigit(number)
                    }
                }
            }
            GridRow {
                ForEach(4...6, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.inputDigit(number)
                    }
                }
            }
            GridRow {
                ForEach(1...3, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.inputDigit(number)
                    }
                }
            }
            GridRow {
                ClearAllButton {
                    viewModel.clearAllInput()
                }
                NumberButton(number: 0) {
                    viewModel.inputDigit(0)
                }
                // 占位符，保持布局一致性
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
    // MARK: - 结果覆盖层
    private var resultOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 结果图标
                Image(systemName: viewModel.isCorrectAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.isCorrectAnswer ? Color.starlightYellow : Color.alertRed)
                
                // 结果文本
                Text(viewModel.isCorrectAnswer ? LocalizedKeys.correct.localized : LocalizedKeys.incorrect.localized)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.cometWhite)
                
                // 正确答案
                if !viewModel.isCorrectAnswer, let question = viewModel.currentQuestion {
                    Text(LocalizedKeys.correctAnswer.localized + ": \(question.correctAnswer)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.starlightYellow)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.stardustPurple.opacity(0.9))
            )
        }
    }
}

// MARK: - 数字按钮
private struct NumberButton: View {
    let number: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.cometWhite)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red) // 临时背景色，用于调试
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.stardustPurple, lineWidth: 2)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 清空按钮
private struct ClearAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("清空")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.alertRed)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.7)) // 临时背景色，用于调试
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.alertRed, lineWidth: 2)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预览
struct GamePlayView_Previews: PreviewProvider {
    static var previews: some View {
        GamePlayView(level: 1)
            .previewInterfaceOrientation(.portrait)
    }
}