//
//  ResultView.swift
//  Mathaxy
//
//  游戏结果视图
//  显示游戏完成后的成绩和统计
//  Q版化：使用 QBackground + QPrimaryButton + QSecondaryButton + QCardStyle
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
        // Q版背景容器：使用 result 背景图
        QBackground(pageType: .result) {
            VStack(spacing: 0) {
                // 顶部导航
                topBar
                
                Spacer()
                
                // 结果内容
                resultContent
                
                Spacer()
                
                // 底部按钮
                bottomButtons
                    .padding(.bottom, QSpace.xl)
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
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            
            Spacer()
            
            // 标题：使用 Q 版字体 token
            Text(LocalizedKeys.result.localized)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Spacer()
            
            // 分享按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                showShareSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
        }
        .padding(.horizontal, QSpace.pagePadding)
        .padding(.top, QSpace.s)
    }
    
    // MARK: - 结果内容
    private var resultContent: some View {
        VStack(spacing: QSpace.xl) {
            // 成绩图标
            HStack {
                Spacer()
                resultIcon
                Spacer()
            }
            
            // 成绩统计
            statisticsView
            
            // 星级评价
            starRating
        }
        .padding(.horizontal, QSpace.pagePadding)
    }
    
    // MARK: - 成绩图标（Q版样式）
    private var resultIcon: some View {
        ZStack {
            // 背景圆圈
            Circle()
                .fill(gameSession.isPassed ? QColor.brand.accent.opacity(0.2) : QColor.state.danger.opacity(0.2))
                .frame(width: QSize.avatar, height: QSize.avatar)
            
            // Q版反馈图标
            Image(gameSession.isPassed ? QAsset.feedback.correct : QAsset.feedback.incorrect)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160) // 图标放大2倍，横向居中
        }
    }
    
    // MARK: - 统计视图（Q版卡片样式）
    private var statisticsView: some View {
        VStack(spacing: QSpace.m) {
            // 关卡信息
            HStack {
                Text(LocalizedKeys.level.localized)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Spacer()
                
                Text("\(gameSession.level)")
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.brand.accent)
            }
            
            // 正确率
            HStack {
                Text(LocalizedKeys.accuracy.localized)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Spacer()
                
                Text(String(format: "%.1f%%", gameSession.accuracy * 100))
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.brand.accent)
            }
            
            // 用时
            HStack {
                Text(LocalizedKeys.timeSpent.localized)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Spacer()
                
                Text(String(format: "%.1f \(LocalizedKeys.seconds.localized)", gameSession.totalTime))
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.brand.accent)
            }
            
            // 正确题数
            HStack {
                Text(LocalizedKeys.correctAnswers.localized)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Spacer()
                
                Text("\(gameSession.correctCount)/\(gameSession.questionCount)")
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.brand.accent)
            }
        }
        .padding(QSpace.l)
        .qCardStyle() // 使用 Q 版卡片样式
    }
    
    // MARK: - 星级评价（Q版星星装饰）
    private var starRating: some View {
        HStack(spacing: QSpace.s) {
            ForEach(0..<3, id: \.self) { index in
                Image(index < viewModel.starRating ? QAsset.decoration.star : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64) // 成就图标放大2倍，横向居中
                    .foregroundColor(index < viewModel.starRating ? QColor.brand.accent : QColor.text.onDarkSecondary.opacity(0.3))
            }
        }
    }
    
    // MARK: - 底部按钮（使用 Q 版按钮组件）
    private var bottomButtons: some View {
        VStack(spacing: QSpace.m) {
            // 生成奖状按钮：使用 QPrimaryButton
            QPrimaryButton(
                title: LocalizedKeys.generateCertificate.localized,
                action: {
                    SoundService.shared.playButtonClickSound()
                    showCertificate = true
                }
            )
            .padding(.horizontal, QSpace.pagePadding)
            
            // 重试按钮：使用 QSecondaryButton
            QSecondaryButton(
                title: LocalizedKeys.retry.localized,
                action: {
                    SoundService.shared.playButtonClickSound()
                    // TODO: 重新开始游戏
                    dismiss()
                }
            )
            .padding(.horizontal, QSpace.pagePadding)
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