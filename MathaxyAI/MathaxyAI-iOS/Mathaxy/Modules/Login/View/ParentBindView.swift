//
//  ParentBindView.swift
//  Mathaxy
//
//  家长辅助绑定页面（Q版风格）
//  允许家长为孩子设置昵称
//  改造说明：
//  - 背景使用 QBackground(pageType: .login) 替换渐变+随机星点
//  - 确认按钮使用 QPrimaryButton，支持 loading 状态
//  - 返回按钮使用 Q 版装饰样式
//  - 图标使用 Q 版数学符号装饰
//  - 输入框使用 QCardStyle 统一样式
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
        // 使用 Q 版统一背景容器
        QBackground(pageType: .login) {
            contentView
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
    
    // MARK: - 顶部导航栏（Q版风格）
    private var topBar: some View {
        HStack {
            // 返回按钮 - 使用 Q 版装饰样式
            Button(action: {
                SoundService.shared.playButtonClickSound()
                dismiss()
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
            
            Spacer()
        }
        .padding(.top, QSpace.s)
    }
    
    // MARK: - 表单视图
    private var formView: some View {
        VStack(spacing: QSpace.l) {
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
        .padding(.horizontal, QSpace.pagePadding)
    }
    
    // MARK: - 图标视图（Q版风格）
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(QColor.brand.accent.opacity(0.2))
                .frame(width: 100, height: 100)
            
            // 使用 Q 版数学符号装饰
            Image(QAsset.decoration.mathSymbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
        }
    }
    
    // MARK: - 标题视图（Q版风格）
    private var titleView: some View {
        VStack(spacing: QSpace.s) {
            Text(LocalizedKeys.parentBind.localized)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
            
            Text(LocalizedKeys.setNicknameHint.localized)
                .font(QFont.body)
                .foregroundColor(QColor.text.onDarkSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - 昵称输入视图（Q版风格）
    private var nicknameInputView: some View {
        VStack(alignment: .leading, spacing: QSpace.s) {
            Text(LocalizedKeys.enterNickname.localized)
                .font(QFont.body)
                .foregroundColor(QColor.text.onDarkSecondary)
            
            TextField("", text: $viewModel.nickname)
                .textFieldStyle(QParentBindTextFieldStyle())
                .font(QFont.body)
                .onChange(of: viewModel.nickname) {
                    viewModel.clearError()
                }
        }
    }
    
    // MARK: - 确认按钮视图（Q版风格）
    private var confirmButtonView: some View {
        // 使用 QPrimaryButton，支持 loading 状态
        QPrimaryButton(
            title: LocalizedKeys.confirm.localized,
            isLoading: viewModel.isSaving,
            isDisabled: viewModel.isSaving
        ) {
            viewModel.parentBind()
            // 登录成功后关闭页面
            if viewModel.onLoginSuccess != nil {
                dismiss()
            }
        }
    }
    
    // MARK: - 错误消息视图（Q版风格）
    private var errorMessageView: some View {
        Text(viewModel.errorMessage)
            .font(QFont.caption)
            .foregroundColor(QColor.state.danger)
            .padding(.top, QSpace.s)
            .transition(.opacity)
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

// MARK: - Q版家长绑定文本框样式
/// Q版风格的家长绑定文本框样式
/// 使用 QCardStyle token 统一圆角、描边、背景
struct QParentBindTextFieldStyle: TextFieldStyle {
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
struct ParentBindView_Previews: PreviewProvider {
    static var previews: some View {
        ParentBindView()
            .previewInterfaceOrientation(.portrait)
    }
}
