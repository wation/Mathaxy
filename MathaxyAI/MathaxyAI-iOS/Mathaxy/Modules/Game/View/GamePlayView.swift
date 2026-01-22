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
        ZStack {
            Color.black.ignoresSafeArea(edges: .all) // 状态栏遮挡
            backgroundView
            VStack(spacing: 0) {
                topInfoBar
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // 调整计算框位置，减小顶部间距
                Spacer().frame(height: 20)
                
                if let question = viewModel.currentQuestion {
                    questionArea(question: question)
                } else {
                    loadingView
                }
                
                Spacer()
                
                // 进度条：居中显示在计算框和键盘之间
                if !viewModel.isGameCompleted {
                    ProgressView(value: viewModel.progress)
                        .tint(Color.starlightYellow)
                        .scaleEffect(y: 2)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                if !viewModel.isGameCompleted {
                    answerGrid
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if viewModel.showResult {
                resultOverlay
            }
            if showExitAlert {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 24) {
                        Text("是否退出当前游戏？")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.starlightYellow)
                            .padding(.top, 24)
                        Text("退出后将丢失当前进度")
                            .font(.system(size: 16))
                            .foregroundColor(Color.cometWhite.opacity(0.8))
                            .padding(.horizontal, 24)
                        HStack(spacing: 20) {
                            Button(action: { showExitAlert = false }) {
                                Text("取消")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.starlightYellow)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.stardustPurple.opacity(0.7)))
                            }
                            Button(action: { dismiss() }) {
                                Text("退出")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.alertRed))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.galaxyGradient))
                    .padding(.horizontal, 32)
                    .scaleEffect(showExitAlert ? 1 : 0.8)
                    .opacity(showExitAlert ? 1 : 0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: showExitAlert)
                }
            }
        }
        .statusBar(hidden: hideStatusBar)
        .onAppear { hideStatusBar = true; viewModel.startGame() }
        .onDisappear { hideStatusBar = false; viewModel.pauseGame() }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .fullScreenCover(isPresented: $viewModel.showGameComplete) {
            ResultView(gameSession: viewModel.gameSession)
                .onDisappear {
                    dismiss()
                }
        }
    }
    
    // MARK: - 背景视图
    private var backgroundView: some View {
        ZStack {
            // 银河背景渐变 - 全屏
            Color.galaxyGradient
                .ignoresSafeArea(.all)
            
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
                showExitAlert = true
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 32, weight: .bold)) // 增大返回按钮
                    .foregroundColor(Color.starlightYellow)
            }
            
            Spacer()
            
            // 关卡信息
            VStack(spacing: 6) { // 增加间距
                Text(LocalizedKeys.level.localized + " \(viewModel.level)")
                    .font(.system(size: 24, weight: .bold)) // 增大关卡标题
                    .foregroundColor(Color.cometWhite.opacity(0.9))
                
                Text("\(viewModel.currentQuestionIndex + 1)/\(viewModel.totalQuestions)")
                    .font(.system(size: 18, weight: .semibold)) // 增大进度文字
                    .foregroundColor(Color.cometWhite.opacity(0.7))
            }
            
            Spacer()
            
            // 计时器
            VStack(spacing: 6) { // 增加间距
                Text(LocalizedKeys.time.localized)
                    .font(.system(size: 16, weight: .semibold)) // 增大时间标签
                    .foregroundColor(Color.cometWhite.opacity(0.9))
                
                // 对于第7-10关需要显示到0.1s精度
                let config = LevelConfig.getLevelConfig(viewModel.level)
                if config.mode == .perQuestion {
                    Text(String(format: "%.1f", max(0, viewModel.timeRemaining)))
                        .font(.system(size: 24, weight: .bold)) // 增大时间数值
                        .foregroundColor(viewModel.timeRemaining < 10 ? Color.alertRed : Color.starlightYellow)
                } else {
                    Text(String(format: "%.0f", viewModel.timeRemaining))
                        .font(.system(size: 24, weight: .bold)) // 增大时间数值
                        .foregroundColor(viewModel.timeRemaining < 10 ? Color.alertRed : Color.starlightYellow)
                }
            }
        }
        .padding(.vertical, 10) // 增加垂直内边距，使标题栏整体更高
    }
    
    // MARK: - 题目区域
    private func questionArea(question: Question) -> some View {
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
                .foregroundColor(
                    viewModel.hasInputError ? Color.alertRed :
                    (viewModel.userInputAnswer.isEmpty ? Color.stardustPurple : Color.starlightYellow)
                )
                .frame(minWidth: 80)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.stardustPurple.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.starlightYellow, lineWidth: 2)
                )
        )
        .padding(.horizontal, 16)
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
                        viewModel.playButtonClickSound()
                        viewModel.inputDigit(number)
                    }
                }
            }
            GridRow {
                ForEach(4...6, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.playButtonClickSound()
                        viewModel.inputDigit(number)
                    }
                }
            }
            GridRow {
                ForEach(1...3, id: \.self) { number in
                    NumberButton(number: number) {
                        viewModel.playButtonClickSound()
                        viewModel.inputDigit(number)
                    }
                }
            }
            GridRow {
                ClearAllButton {
                    viewModel.playButtonClickSound()
                    viewModel.clearAllInput()
                }
                NumberButton(number: 0) {
                    viewModel.playButtonClickSound()
                    viewModel.inputDigit(0)
                }
                ClearAllButton {
                    viewModel.playButtonClickSound()
                    viewModel.clearAllInput()
                }
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
                        .fill(Color.stardustPurple.opacity(0.3))
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
                .foregroundColor(.white)
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

// MARK: - 退格按钮
private struct BackspaceButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "delete.left")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
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