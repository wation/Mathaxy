//
//  LoginView.swift
//  Mathaxy
//
//  登录页面
//  提供游客登录和家长辅助绑定两种登录方式
//

import SwiftUI

// MARK: - 登录页面
struct LoginView: View {
    
    // MARK: - 视图模型
    @StateObject private var viewModel = LoginViewModel()
    
    // MARK: - 导航状态
    @State private var showParentBind = false
    
    // MARK: - 登录完成回调
    var onLoginSuccess: ((UserProfile) -> Void)?
    
    // MARK: - 初始化
    init(onLoginSuccess: ((UserProfile) -> Void)? = nil) {
        self.onLoginSuccess = onLoginSuccess
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            contentView
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.onLoginSuccess = onLoginSuccess
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
                        .fill(Color.starlightYellow.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 2...6))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo和标题
            logoView
            
            Spacer()
            
            // 登录选项
            if showParentBind {
                parentBindView
            } else {
                guestLoginView
            }
            
            Spacer()
            
            // 版本信息
            versionView
                .padding(.bottom, 40)
        }
    }
    
    // MARK: - Logo和标题视图
    private var logoView: some View {
        VStack(spacing: 20) {
            // Logo占位图
            ZStack {
                Circle()
                    .fill(Color.starlightYellow.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "star.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color.starlightYellow)
            }
            
            // 应用名称
            Text(LocalizedKeys.appName.localized)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color.starlightYellow)
        }
        .padding(.top, 80)
    }
    
    // MARK: - 游客登录视图
    private var guestLoginView: some View {
        VStack(spacing: 30) {
            // 游客登录按钮
            Button(action: {
                viewModel.guestLogin()
            }) {
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                    
                    Text(LocalizedKeys.guestLogin.localized)
                        .font(.system(size: 20, weight: .semibold))
                }
                .foregroundColor(Color.spaceBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .primaryButtonStyle()
            .padding(.horizontal, 40)
            
            // 家长辅助绑定按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                withAnimation(.spring()) {
                    showParentBind = true
                }
            }) {
                HStack {
                    Image(systemName: "link")
                        .font(.title2)
                    
                    Text(LocalizedKeys.parentBind.localized)
                        .font(.system(size: 18, weight: .medium))
                }
                .foregroundColor(Color.starlightYellow)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .secondaryButtonStyle()
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - 家长辅助绑定视图
    private var parentBindView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 30) {
                // 返回按钮
                Button(action: {
                    SoundService.shared.playButtonClickSound()
                    withAnimation(.spring()) {
                        showParentBind = false
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        
                        Text(LocalizedKeys.back.localized)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .foregroundColor(Color.starlightYellow)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                // 昵称输入
                VStack(alignment: .leading, spacing: 10) {
                    Text(LocalizedKeys.enterNickname.localized)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.cometWhite.opacity(0.8))
                    
                    TextField("", text: $viewModel.nickname)
                        .textFieldStyle(LoginTextFieldStyle())
                        .font(.system(size: 18))
                        .padding(.horizontal, 20)
                        .onChange(of: viewModel.nickname) {
                            viewModel.clearError()
                        }
                }
                .padding(.horizontal, 40)
                
                // 确认按钮
                Button(action: {
                    viewModel.parentBind()
                }) {
                    if viewModel.isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.spaceBlue))
                    } else {
                        Text(LocalizedKeys.confirm.localized)
                            .font(.system(size: 20, weight: .semibold))
                    }
                }
                .foregroundColor(Color.spaceBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .disabled(viewModel.isSaving)
            }
            .primaryButtonStyle()
            .padding(.horizontal, 40)
            
            // 错误提示
            if viewModel.showError {
                Text(viewModel.errorMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.alertRed)
                    .padding(.top, 10)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - 版本信息视图
    private var versionView: some View {
        VStack(spacing: 5) {
            Text(AppVersionInfo.fullVersion)
                .font(.system(size: 12))
                .foregroundColor(Color.cometWhite.opacity(0.6))
            
            Text(AppVersionInfo.copyright)
                .font(.system(size: 10))
                .foregroundColor(Color.cometWhite.opacity(0.4))
        }
    }
}

// MARK: - 圆角边框文本框样式
struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(Color.cometWhite.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.starlightYellow, lineWidth: 2)
            )
    }
}

// MARK: - 预览
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.portrait)
    }
}
