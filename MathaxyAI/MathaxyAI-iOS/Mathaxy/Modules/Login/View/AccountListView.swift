//
//  AccountListView.swift
//  Mathaxy
//
//  账号列表视图（Q版风格）
//  显示已登录账号，支持切换和添加新账号
//  改造说明：
//  - 背景使用 QBackground(pageType: .settings) 替换纯色背景
//  - 账号卡片使用 QCardStyle 统一样式
//  - 添加新账号按钮使用 QSecondaryButton
//  - 标题栏关闭按钮使用 Q 版装饰样式
//

import SwiftUI

// MARK: - 账号列表视图
struct AccountListView: View {
    
    // MARK: - 视图模型
    @StateObject private var viewModel = AccountListViewModel()
    
    // MARK: - 环境变量
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storageService: StorageService
    
    // MARK: - 登录成功回调
    var onAccountSwitch: (() -> Void)?
    
    // MARK: - 关闭父级页面回调
    var dismissParent: (() -> Void)?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            // 使用 Q 版统一背景容器（settings 背景，因为账号列表属于设置类入口）
            QBackground(pageType: .settings) {
                contentView
            }
        }
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        VStack {
            // 标题栏
            headerBar
            
            // 账号列表
            ScrollView {
                VStack(spacing: QSpace.m) {
                    // 账号列表
                    ForEach(viewModel.accounts) { account in
                        QAccountRowView(
                            account: account,
                            isCurrent: viewModel.isCurrentAccount(account.id),
                            onTap: {
                                viewModel.switchToAccount(account.id)
                                onAccountSwitch?()
                                dismiss()
                                dismissParent?()
                            },
                            onDelete: {
                                viewModel.deleteAccount(account.id)
                            }
                        )
                    }
                    
                    // 添加新账号按钮 - 使用 QSecondaryButton
                    QSecondaryButton(
                        title: "添加新账号",
                        isLoading: false,
                        isDisabled: false
                    ) {
                        // 1. 准备添加新账号（清除登录状态）
                        viewModel.prepareForAddAccount()
                        
                        // 2. 通知回调
                        onAccountSwitch?()
                        
                        // 3. 关闭当前页面
                        dismiss()
                        
                        // 4. 关闭父级页面
                        dismissParent?()
                    }
                }
                .padding(.vertical, QSpace.l)
            }
            
            Spacer()
        }
    }
    
    // MARK: - 标题栏（Q版风格）
    private var headerBar: some View {
        HStack {
            Text("账号切换")
                .font(QFont.titlePage)
                .foregroundColor(QColor.brand.accent)
            
            Spacer()
            
            // 关闭按钮 - 使用 Q 版装饰样式
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(QColor.text.onDarkPrimary.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(QColor.text.onDarkPrimary)
                }
            }
        }
        .padding(QSpace.l)
        .padding(.top, QSpace.s)
    }
}

// MARK: - Q版账号行视图
/// Q版风格的账号卡片视图
/// 使用 QCardStyle 统一圆角、描边、阴影
struct QAccountRowView: View {
    
    // MARK: - 属性
    let account: AccountInfo
    let isCurrent: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: QSpace.m) {
            // 头像占位符 - 使用 Q 版装饰
            ZStack {
                Circle()
                    .fill(QColor.text.onDarkPrimary.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Text(String(account.nickname.first ?? "?"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(QColor.brand.accent)
            }
            
            // 账号信息
            VStack(alignment: .leading, spacing: 4) {
                Text(account.nickname)
                    .font(QFont.body)
                    .fontWeight(.semibold)
                    .foregroundColor(QColor.text.onDarkPrimary)
                
                Text("上次登录: \(formatDate(account.lastLoginAt))")
                    .font(QFont.caption)
                    .foregroundColor(QColor.text.onDarkSecondary)
            }
            
            Spacer()
            
            // 当前账号标记
            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(QColor.state.success)
            }
            
            // 删除按钮
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18))
                    .foregroundColor(QColor.state.danger)
            }
        }
        .padding(QSpace.l)
        .modifier(QCardStyle(radius: QRadius.card))
        .onTapGesture(perform: onTap)
    }
    
    // MARK: - 日期格式化
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 预览
#Preview {
    AccountListView()
        .environmentObject(StorageService.shared)
}
