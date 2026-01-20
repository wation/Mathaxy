//
//  ParentBindView.swift
//  Mathaxy
//
//  家长辅助绑定页面
//  允许家长为孩子设置昵称
//

import SwiftUI

// MARK: - 家长辅助绑定页面
struct ParentBindView: View {
    
    // MARK: - 视图模型
    @StateObject private var viewModel = LoginViewModel()
    
    // MARK: - 导航状态
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景
            backgroundView
            
            // 内容
            contentView
        }
        .ignoresSafeArea()
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
                        .fill(Color.starlightYellow.opacity(Double.random(in: 0.3...0.7)))
                        .frame(width: CGFloat.random(in: 2...5))
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
            
            // 顶部导航
            topBar
            
            Spacer()
            
            // 表单区域
            formView
            
            Spacer()
            
            // 版本信息
            versionView
                .padding(.bottom, 40)
        }
    }
    
    // MARK: - 顶部导航栏
    private var topBar: some View {
        HStack {
            // 返回按钮
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                    
                    Text(LocalizedKeys.back.localized)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Color.starlightYellow)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // MARK: - 表单视图
    private var formView: some View {
        VStack(spacing: 30) {
            // 图标
            iconView
            
            // 标题
            titleView
            
            // 昵称输入
            nicknameInputView
            
            // 确认按钮
            confirmButtonView
            
            // 错误提示
            if viewModel.showError {
                errorMessageView
            }
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - 图标视图
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(Color.starlightYellow.opacity(0.2))
                .frame(width: 100, height: 100)
            
            Image(systemName: "link.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(Color.starlightYellow)
        }
    }
    
    // MARK: - 标题视图
    private var titleView: some View {
        VStack(spacing: 10) {
            Text(LocalizedKeys.parentBind.localized)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.cometWhite)
            
            Text("为孩子设置一个可爱的昵称吧！")
                .font(.system(size: 16))
                .foregroundColor(Color.cometWhite.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - 昵称输入视图
    private var nicknameInputView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(LocalizedKeys.enterNickname.localized)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.cometWhite.opacity(0.8))
            
            TextField("", text: $viewModel.nickname)
                        .textFieldStyle(ParentBindTextFieldStyle())
                        .font(.system(size: 18))
                        .padding(.horizontal, 20)
                .onChange(of: viewModel.nickname) {
                    viewModel.clearError()
                }
        }
    }
    
    // MARK: - 确认按钮视图
    private var confirmButtonView: some View {
        Button(action: {
            viewModel.parentBind()
            // 登录成功后关闭页面
            if viewModel.onLoginSuccess != nil {
                dismiss()
            }
        }) {
            if viewModel.isSaving {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.spaceBlue))
                        .scaleEffect(1.2)
                    
                    Text("保存中...")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color.spaceBlue)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                Text(LocalizedKeys.confirm.localized)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.spaceBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .primaryButtonStyle()
        .disabled(viewModel.isSaving)
    }
    
    // MARK: - 错误消息视图
    private var errorMessageView: some View {
        Text(viewModel.errorMessage)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color.alertRed)
            .padding(.top, 10)
            .transition(.opacity)
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
struct ParentBindTextFieldStyle: TextFieldStyle {
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
struct ParentBindView_Previews: PreviewProvider {
    static var previews: some View {
        ParentBindView()
            .previewInterfaceOrientation(.portrait)
    }
}
