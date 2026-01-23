//
//  LoginView.swift
//  Mathaxy
//
//  登录页面（Q版风格）
//  提供游客登录和家长辅助绑定两种登录方式
//  改造说明：
//  - 背景使用 QBackground(pageType: .login) 替换原有的渐变+随机星点
//  - 主按钮使用 QPrimaryButton，次按钮使用 QSecondaryButton
//  - 输入框使用 QCardStyle 统一样式
//  - Logo 区使用 Q 版装饰（星星装饰）
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
        // 使用 Q 版统一背景容器
        QBackground(pageType: .login) {
            contentView
        }
        .onAppear {
            viewModel.onLoginSuccess = onLoginSuccess
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
    
    // MARK: - Logo和标题视图（Q版风格）
    private var logoView: some View {
        VStack(spacing: QSpace.l) {
            // Logo 占位图 - 使用 Q 版星星装饰
            ZStack {
                Circle()
                    .fill(QColor.brand.accent.opacity(0.2))
                    .frame(width: QSize.avatar, height: QSize.avatar)
                
                // 使用 Q 版星星装饰图标
                Image(QAsset.decoration.star)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
            }
            
            // 应用名称 - 使用 Q 版字体 token
            Text(LocalizedKeys.appName.localized)
                .font(QFont.displayHero)
                .foregroundColor(QColor.brand.accent)
        }
        .padding(.top, QSpace.xl)
    }
    
    // MARK: - 游客登录视图（Q版风格）
    private var guestLoginView: some View {
        VStack(spacing: QSpace.l) {
            // 游客登录按钮 - 使用 QPrimaryButton
            QPrimaryButton(
                title: LocalizedKeys.guestLogin.localized,
                isLoading: false,
                isDisabled: false
            ) {
                viewModel.guestLogin()
            }
            
            // 家长辅助绑定按钮 - 使用 QSecondaryButton
            QSecondaryButton(
                title: LocalizedKeys.parentBind.localized,
                isLoading: false,
                isDisabled: false
            ) {
                SoundService.shared.playButtonClickSound()
                withAnimation(.spring()) {
                    showParentBind = true
                }
            }
        }
        .padding(.horizontal, QSpace.pagePadding)
    }
    
    // MARK: - 家长辅助绑定视图（Q版风格）
    private var parentBindView: some View {
        VStack(spacing: QSpace.l) {
            VStack(spacing: QSpace.l) {
                // 返回按钮 - 使用 QSecondaryButton 小尺寸
                Button(action: {
                    SoundService.shared.playButtonClickSound()
                    withAnimation(.spring()) {
                        showParentBind = false
                    }
                }) {
                    HStack(spacing: QSpace.xs) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                        
                        Text(LocalizedKeys.back.localized)
                            .font(QFont.body)
                    }
                    .foregroundColor(QColor.brand.accent)
                }
                .padding(.horizontal, QSpace.m)
                .padding(.vertical, QSpace.s)
                
                // 昵称输入 - 使用 QCardStyle
                VStack(alignment: .leading, spacing: QSpace.s) {
                    Text(LocalizedKeys.enterNickname.localized)
                        .font(QFont.body)
                        .foregroundColor(QColor.text.onDarkSecondary)
                    
                    TextField("", text: $viewModel.nickname)
                        .textFieldStyle(QLoginTextFieldStyle())
                        .font(QFont.body)
                        .onChange(of: viewModel.nickname) {
                            viewModel.clearError()
                        }
                }
                
                // 确认按钮 - 使用 QPrimaryButton，支持 loading 状态
                QPrimaryButton(
                    title: LocalizedKeys.confirm.localized,
                    isLoading: viewModel.isSaving,
                    isDisabled: viewModel.isSaving
                ) {
                    viewModel.parentBind()
                }
            }
            .padding(.horizontal, QSpace.pagePadding)
            
            // 错误提示
            if viewModel.showError {
                Text(viewModel.errorMessage)
                    .font(QFont.caption)
                    .foregroundColor(QColor.state.danger)
                    .padding(.top, QSpace.s)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - 版本信息视图（Q版风格）
    private var versionView: some View {
        VStack(spacing: 5) {
            Text(AppVersionInfo.fullVersion)
                .font(QFont.caption)
                .foregroundColor(QColor.text.onDarkSecondary)
            
            Text(AppVersionInfo.copyright)
                .font(.system(size: 10))
                .foregroundColor(QColor.text.onDarkSecondary.opacity(0.7))
        }
    }
}

// MARK: - Q版登录文本框样式
/// Q版风格的登录文本框样式
/// 使用 QCardStyle token 统一圆角、描边、背景
struct QLoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, QSpace.m)
            .padding(.vertical, QSpace.s)
            .background(QColor.text.onDarkPrimary.opacity(0.1))
            .cornerRadius(QRadius.chip)
            .overlay(
                RoundedRectangle(cornerRadius: QRadius.chip)
                    .stroke(QColor.brand.accent, lineWidth: QStroke.thin)
            )
            .foregroundColor(QColor.text.onDarkPrimary)
    }
}

// MARK: - 预览
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.portrait)
    }
}
