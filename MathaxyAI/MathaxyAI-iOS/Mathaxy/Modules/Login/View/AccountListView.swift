//
//  AccountListView.swift
//  Mathaxy
//
//  账号列表视图
//  显示已登录账号，支持切换和添加新账号
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
            ZStack {
                // 背景
                Color.spaceBlue
                    .ignoresSafeArea()
                
                // 内容
                VStack {
                    // 标题栏
                    HStack {
                        Text("账号切换")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.starlightYellow)
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color.cometWhite)
                        }
                    }
                    .padding(20)
                    
                    // 账号列表
                    ScrollView {
                        VStack(spacing: 16) {
                            // 账号列表
                            ForEach(viewModel.accounts) { account in
                                AccountRowView(
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
                            
                            // 添加新账号按钮
                            Button(action: { viewModel.addNewAccount() }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.starlightYellow)
                                        .frame(width: 30)
                                    
                                    Text("添加新账号")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.cometWhite)
                                    
                                    Spacer()
                                }
                                .padding(20)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.stardustPurple.opacity(0.3)))
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $viewModel.showAddAccount) {
                LoginView(onLoginSuccess: { profile in
                    // 1. 调用切换账号逻辑
                    // 这会更新最后登录时间，并发送 .accountSwitched 通知
                    // RootView 收到通知后会重置整个 UI 栈，返回首页
                    viewModel.switchToAccount(profile.id)
                    
                    // 2. 记录操作日志
                    print("AccountListView: New account created and switched: \(profile.nickname)")
                    
                    // 3. 执行外部回调
                    onAccountSwitch?()
                    
                    // 4. 关闭当前页面
                    dismiss()
                    
                    // 5. 关闭父级页面
                    dismissParent?()
                    
                    // 6. 刷新列表状态
                    viewModel.refreshAccounts()
                })
            }
        }
    }
}

// MARK: - 账号行视图
private struct AccountRowView: View {
    
    // MARK: - 属性
    let account: AccountInfo
    let isCurrent: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 15) {
            // 头像占位符
            ZStack {
                Circle()
                    .fill(Color.stardustPurple.opacity(0.5))
                    .frame(width: 50, height: 50)
                
                Text(String(account.nickname.first ?? "?"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.starlightYellow)
            }
            
            // 账号信息
            VStack(alignment: .leading, spacing: 4) {
                Text(account.nickname)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.cometWhite)
                
                Text("上次登录: \(formatDate(account.lastLoginAt))")
                    .font(.system(size: 12))
                    .foregroundColor(Color.cometWhite.opacity(0.7))
            }
            
            Spacer()
            
            // 当前账号标记
            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.starlightYellow)
            }
            
            // 删除按钮
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.alertRed)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 12).fill(isCurrent ? Color.stardustPurple.opacity(0.5) : Color.stardustPurple.opacity(0.3)))
        .padding(.horizontal, 20)
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