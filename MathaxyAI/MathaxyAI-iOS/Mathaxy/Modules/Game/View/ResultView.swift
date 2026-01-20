//
//  ResultView.swift
//  Mathaxy
//
//  游戏结果视图
//  显示游戏完成后的成绩和统计
//

import SwiftUI

// MARK: - 游戏结果视图
struct ResultView: View {
    
    // MARK: - 游戏会话
    let gameSession: GameSession
    
    // MARK: - 视图模型
    @StateObject private var viewModel = ResultViewModel()
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 状态
    @State private var showShareSheet = false
    @State private var showCertificate = false
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            VStack(spacing: 0) {
                // 顶部导航
                topBar
                
                Spacer()
                
                // 结果内容
                resultContent
                
                Spacer()
                
                // 底部按钮
                bottomButtons
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showCertificate) {
            CertificateView(gameSession: gameSession)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: viewModel.getShareItems(for: gameSession))
        }
        .onAppear {
            SoundService.shared.playGameCompleteSound()
            viewModel.saveGameResult(gameSession)
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
                ForEach(0..<30, id: \.self) { index in
                    Circle()
                        .fill(Color.starlightYellow.opacity(Double.random(in: 0.2...0.6)))
                        .frame(width: CGFloat.random(in: 2...5))
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
            Text(LocalizedKeys.result.localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.starlightYellow)
            
            Spacer()
            
            // 分享按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                showShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - 结果内容
    private var resultContent: some View {
        VStack(spacing: 30) {
            // 成绩图标
            resultIcon
            
            // 成绩统计
            statisticsView
            
            // 星级评价
            starRating
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - 成绩图标
    private var resultIcon: some View {
        ZStack {
            // 背景圆圈
            Circle()
                .fill(!gameSession.isFailed ? Color.starlightYellow.opacity(0.2) : Color.alertRed.opacity(0.2))
                .frame(width: 120, height: 120)
            
            // 图标
            Image(systemName: !gameSession.isFailed ? "star.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(!gameSession.isFailed ? Color.starlightYellow : Color.alertRed)
        }
    }
    
    // MARK: - 统计视图
    private var statisticsView: some View {
        VStack(spacing: 20) {
            // 关卡信息
            HStack {
                Text(LocalizedKeys.level.localized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Spacer()
                
                Text("\(gameSession.level)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
            }
            
            // 正确率
            HStack {
                Text(LocalizedKeys.accuracy.localized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Spacer()
                
                Text(String(format: "%.1f%%", gameSession.accuracy * 100))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
            }
            
            // 用时
            HStack {
                Text(LocalizedKeys.timeSpent.localized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Spacer()
                
                Text(String(format: "%.1f \(LocalizedKeys.seconds.localized)", gameSession.totalTime))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
            }
            
            // 正确题数
            HStack {
                Text(LocalizedKeys.correctCount.localized)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.cometWhite.opacity(0.8))
                
                Spacer()
                
                Text("\(gameSession.correctCount)/\(gameSession.questions.count)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.stardustPurple.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.starlightYellow.opacity(0.5), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 星级评价
    private var starRating: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < viewModel.starRating ? "star.fill" : "star")
                    .font(.system(size: 30))
                    .foregroundColor(index < viewModel.starRating ? Color.starlightYellow : Color.cometWhite.opacity(0.3))
            }
        }
    }
    
    // MARK: - 底部按钮
    private var bottomButtons: some View {
        VStack(spacing: 15) {
            // 生成奖状按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                showCertificate = true
            }) {
                HStack {
                    Image(systemName: "doc.badge.gearshape.fill")
                        .font(.title2)
                    
                    Text(LocalizedKeys.certificate.localized)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(Color.spaceBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .primaryButtonStyle()
            .padding(.horizontal, 40)
            
            // 重试按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                // TODO: 重新开始游戏
                dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                    
                    Text(LocalizedKeys.retry.localized)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(Color.cometWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .secondaryButtonStyle()
            .padding(.horizontal, 40)
        }
    }
}



// MARK: - 预览
struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        let questions = [
            Question(addend1: 5, addend2: 3),
            Question(addend1: 2, addend2: 7),
            Question(addend1: 4, addend2: 6)
        ]
        let gameSession = GameSession(level: 1, questions: questions)
        ResultView(gameSession: gameSession)
            .previewInterfaceOrientation(.portrait)
    }
}