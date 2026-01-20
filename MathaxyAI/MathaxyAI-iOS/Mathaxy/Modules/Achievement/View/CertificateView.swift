//
//  CertificateView.swift
//  Mathaxy
//
//  奖状视图
//  显示和分享用户获得的奖状
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
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            VStack(spacing: 0) {
                // 顶部导航
                topBar
                
                Spacer()
                
                // 奖状内容
                certificateContent
                
                Spacer()
                
                // 底部按钮
                bottomButtons
                    .padding(.bottom, 40)
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
            Text(LocalizedKeys.certificate.localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.starlightYellow)
            
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
                    .foregroundColor(Color.cometWhite.opacity(0.8))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - 奖状内容
    private var certificateContent: some View {
        VStack(spacing: 30) {
            // 奖状框架
            certificateFrame
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - 奖状框架
    private var certificateFrame: some View {
        VStack(spacing: 20) {
            // 顶部装饰
            topDecoration
            
            // 标题
            certificateTitle
            
            // 副标题
            certificateSubtitle
            
            // 内容
            certificateBody
            
            // 统计信息
            statisticsView
            
            // 底部装饰
            bottomDecoration
            
            // 签名
            signatureView
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cometWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.starlightYellow, lineWidth: 3)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 5)
    }
    
    // MARK: - 顶部装饰
    private var topDecoration: some View {
        HStack {
            // 左侧星星
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.starlightYellow)
            
            Spacer()
            
            // 中间星星
            Image(systemName: "star.fill")
                .font(.system(size: 32))
                .foregroundColor(Color.starlightYellow)
            
            Spacer()
            
            // 右侧星星
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.starlightYellow)
        }
    }
    
    // MARK: - 奖状标题
    private var certificateTitle: some View {
        Text(LocalizedKeys.certificateOfAchievement.localized)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(Color.spaceBlue)
    }
    
    // MARK: - 奖状副标题
    private var certificateSubtitle: some View {
        Text(LocalizedKeys.presentedTo.localized)
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Color.stardustPurple)
    }
    
    // MARK: - 奖状内容
    private var certificateBody: some View {
        VStack(spacing: 15) {
            // 用户名称
            Text(getUserName())
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.starlightYellow)
            
            // 成就描述
            Text(getAchievementDescription())
                .font(.system(size: 16))
                .foregroundColor(Color.spaceBlue)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    // MARK: - 统计信息
    private var statisticsView: some View {
        HStack(spacing: 30) {
            // 关卡
            VStack(spacing: 5) {
                Text(LocalizedKeys.level.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.stardustPurple)
                
                Text("\(gameSession.level)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.spaceBlue)
            }
            
            // 正确率
            VStack(spacing: 5) {
                Text(LocalizedKeys.accuracy.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.stardustPurple)
                
                Text(String(format: "%.1f%%", gameSession.accuracy * 100))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.spaceBlue)
            }
            
            // 用时
            VStack(spacing: 5) {
                Text(LocalizedKeys.time.localized)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.stardustPurple)
                
                Text(String(format: "%.0f", gameSession.totalTime))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.spaceBlue)
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.starlightYellow.opacity(0.2))
        )
    }
    
    // MARK: - 底部装饰
    private var bottomDecoration: some View {
        HStack {
            // 左侧星星
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.starlightYellow)
            
            Spacer()
            
            // 中间星星
            Image(systemName: "star.fill")
                .font(.system(size: 32))
                .foregroundColor(Color.starlightYellow)
            
            Spacer()
            
            // 右侧星星
            Image(systemName: "star.fill")
                .font(.system(size: 24))
                .foregroundColor(Color.starlightYellow)
        }
    }
    
    // MARK: - 签名视图
    private var signatureView: some View {
        VStack(spacing: 5) {
            // 签名线
            Rectangle()
                .fill(Color.stardustPurple)
                .frame(height: 1)
                .padding(.horizontal, 40)
            
            // 签名文字
            Text("Mathaxy Team")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.stardustPurple)
            
            // 日期
            Text(DateHelper.shared.formatFullDate(Date()))
                .font(.system(size: 14))
                .foregroundColor(Color.stardustPurple)
        }
        .padding(.top, 20)
    }
    
    // MARK: - 底部按钮
    private var bottomButtons: some View {
        VStack(spacing: 15) {
            // 保存按钮
            Button(action: {
                saveCertificate()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                    
                    Text(LocalizedKeys.save.localized)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(Color.spaceBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .primaryButtonStyle()
            .padding(.horizontal, 40)
            
            // 关闭按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
            }) {
                HStack {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                    
                    Text(LocalizedKeys.close.localized)
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