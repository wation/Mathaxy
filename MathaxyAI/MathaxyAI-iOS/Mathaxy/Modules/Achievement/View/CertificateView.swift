//
//  CertificateView.swift
//  Mathaxy
//
//  奖状视图
//  显示和分享用户获得的奖状
//  Q版化：使用 QBackground + QPrimaryButton + QSecondaryButton + QCardStyle
//

import SwiftUI

// MARK: - 奖状视图
struct CertificateView: View {
    
    // MARK: - 游戏会话
    let gameSession: GameSession
    
    // MARK: - 视图模型
    @StateObject private var viewModel = CertificateViewModel()
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 状态
    @State private var certificateImage: UIImage?
    @State private var showShareSheet = false
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    
    // MARK: - Body
    var body: some View {
        // Q版背景容器：使用 achievement 背景图
        QBackground(pageType: .achievement) {
            VStack(spacing: 0) {
                // 顶部导航栏
                topBar
                
                Spacer()
                
                // 奖状内容
                certificateContent
                
                Spacer()
                
                // 底部按钮（使用 Q 版按钮组件）
                bottomButtons
                    .padding(.bottom, QSpace.xl)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = certificateImage {
                ShareSheet(activityItems: [image])
            }
        }
        .alert(isPresented: $showSaveAlert) {
            Alert(
                title: Text(LocalizedKeys.save.localized),
                message: Text(saveAlertMessage),
                dismissButton: .default(Text(LocalizedKeys.ok.localized))
            )
        }
        .onAppear {
            generateCertificate()
        }
    }
    
    // MARK: - 顶部导航栏（Q版样式）
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
            Text(LocalizedKeys.certificate.localized)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Spacer()
            
            // 分享按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                if certificateImage != nil {
                    showShareSheet = true
                }
            }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
        }
        .padding(.horizontal, QSpace.pagePadding)
        .padding(.top, QSpace.s)
    }
    
    // MARK: - 奖状内容
    private var certificateContent: some View {
        VStack(spacing: QSpace.xl) {
            // 奖状框架（Q版卡片样式）
            certificateFrame
        }
        .padding(.horizontal, QSpace.pagePadding)
    }
    
    // MARK: - 奖状框架（Q版卡片样式）
    private var certificateFrame: some View {
        VStack(spacing: QSpace.l) {
            // 顶部装饰（Q版星星装饰）
            topDecoration
            
            // 标题：使用 Q 版字体 token
            certificateTitle
            
            // 副标题：使用 Q 版字体 token
            certificateSubtitle
            
            // 内容
            certificateBody
            
            // 统计信息（Q版卡片样式）
            statisticsView
            
            // 底部装饰（Q版星星装饰）
            bottomDecoration
            
            // 签名
            signatureView
        }
        .padding(QSpace.l)
        .qCardStyle() // 使用 Q 版卡片样式
    }
    
    // MARK: - 顶部装饰（Q版星星装饰）
    private var topDecoration: some View {
        HStack {
            // 左侧星星：使用 Q 版装饰资源
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(QColor.brand.accent)
            
            Spacer()
            
            // 中间星星
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(QColor.brand.accent)
            
            Spacer()
            
            // 右侧星星
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(QColor.brand.accent)
        }
    }
    
    // MARK: - 奖状标题（Q版样式）
    private var certificateTitle: some View {
        Text(LocalizedKeys.certificateOfAchievement.localized)
            .font(QFont.titleSection)
            .foregroundColor(QColor.text.onLightPrimary)
    }
    
    // MARK: - 奖状副标题（Q版样式）
    private var certificateSubtitle: some View {
        Text(LocalizedKeys.presentedTo.localized)
            .font(QFont.body)
            .foregroundColor(QColor.text.onDarkSecondary)
    }
    
    // MARK: - 奖状内容（Q版样式）
    private var certificateBody: some View {
        VStack(spacing: QSpace.s) {
            // 用户名称：使用 Q 版字体 token
            Text(getUserName())
                .font(QFont.titlePage)
                .foregroundColor(QColor.brand.accent)
            
            // 成就描述
            Text(getAchievementDescription())
                .font(QFont.body)
                .foregroundColor(QColor.text.onLightPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, QSpace.m)
        }
    }
    
    // MARK: - 统计信息（Q版卡片样式）
    private var statisticsView: some View {
        HStack(spacing: QSpace.l) {
            // 关卡
            VStack(spacing: QSpace.xs) {
                Text(LocalizedKeys.level.localized)
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Text("\(gameSession.level)")
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onLightPrimary)
            }
            
            // 正确率
            VStack(spacing: QSpace.xs) {
                Text(LocalizedKeys.accuracy.localized)
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Text(String(format: "%.1f%%", gameSession.accuracy * 100))
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onLightPrimary)
            }
            
            // 用时
            VStack(spacing: QSpace.xs) {
                Text(LocalizedKeys.time.localized)
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
                
                Text(String(format: "%.0f", gameSession.totalTime))
                    .font(QFont.bodyEmphasis)
                    .foregroundColor(QColor.text.onLightPrimary)
            }
        }
        .padding(.vertical, QSpace.m)
        .padding(.horizontal, QSpace.l)
        .background(QColor.brand.accent.opacity(0.15))
        .cornerRadius(QRadius.chip)
    }
    
    // MARK: - 底部装饰（Q版星星装饰）
    private var bottomDecoration: some View {
        HStack {
            // 左侧星星：使用 Q 版装饰资源
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(QColor.brand.accent)
            
            Spacer()
            
            // 中间星星
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(QColor.brand.accent)
            
            Spacer()
            
            // 右侧星星
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(QColor.brand.accent)
        }
    }
    
    // MARK: - 签名视图（Q版样式）
    private var signatureView: some View {
        VStack(spacing: QSpace.xs) {
            // 签名线
            Rectangle()
                .fill(QColor.text.onDarkSecondary.opacity(0.3))
                .frame(height: 1)
                .padding(.horizontal, QSpace.xl)
            
            // 签名文字：使用 Q 版字体 token
            Text("Mathaxy Team")
                .font(QFont.body)
                .foregroundColor(QColor.text.onDarkSecondary)
            
            // 日期
            Text(DateHelper.shared.formatFullDate(Date()))
                .font(QFont.caption)
                .foregroundColor(QColor.text.onDarkSecondary)
        }
        .padding(.top, QSpace.m)
    }
    
    // MARK: - 底部按钮（使用 Q 版按钮组件）
    private var bottomButtons: some View {
        VStack(spacing: QSpace.m) {
            // 保存按钮：使用 QPrimaryButton
            QPrimaryButton(
                title: LocalizedKeys.save.localized,
                action: {
                    saveCertificate()
                }
            )
            .padding(.horizontal, QSpace.pagePadding)
            
            // 关闭按钮：使用 QSecondaryButton
            QSecondaryButton(
                title: LocalizedKeys.close.localized,
                action: {
                    SoundService.shared.playButtonClickSound()
                    dismiss()
                }
            )
            .padding(.horizontal, QSpace.pagePadding)
        }
    }
    
    // MARK: - 生成奖状图片
    private func generateCertificate() {
        viewModel.generateCertificate(for: gameSession) { image in
            self.certificateImage = image
        }
    }
    
    // MARK: - 保存奖状
    private func saveCertificate() {
        guard let image = certificateImage else {
            saveAlertMessage = LocalizedKeys.saveFailed.localized
            showSaveAlert = true
            return
        }
        
        viewModel.saveCertificateToPhotoLibrary(image) { success, message in
            if success {
                saveAlertMessage = LocalizedKeys.saveSuccess.localized
                SoundService.shared.playSuccessSound()
            } else {
                saveAlertMessage = message
            }
            showSaveAlert = true
        }
    }
    
    // MARK: - 获取用户名称
    private func getUserName() -> String {
        guard let userProfile = StorageService.shared.loadUserProfile() else {
            return "Mathaxy 小勇士"
        }
        return userProfile.nickname
    }
    
    // MARK: - 获取成就描述
    private func getAchievementDescription() -> String {
        return viewModel.getAchievementDescription(for: gameSession)
    }
}



// MARK: - 预览
struct CertificateView_Previews: PreviewProvider {
    static var previews: some View {
        let questions = [
            Question(addend1: 5, addend2: 3),
            Question(addend1: 2, addend2: 7),
            Question(addend1: 4, addend2: 6)
        ]
        let gameSession = GameSession(level: 1, questions: questions)
        CertificateView(gameSession: gameSession)
            .previewInterfaceOrientation(.portrait)
    }
}