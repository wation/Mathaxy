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
                    print("AccountListView: New account added, starting transition sequence")
                    
                    // 1. 关闭添加账号页面 (LoginView)
                    // 必须先关闭当前模态视图，才能处理后续的页面跳转
                    viewModel.showAddAccount = false
                    
                    // 2. 延迟执行以确保视图关闭动画开始
                    // 给予 UI 足够的时间来处理 LoginView 的关闭动画
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        print("AccountListView: Dismissing self and parent")
                        
                        // 3. 关闭当前页面 (AccountListView)
                        dismiss()
                        
                        // 4. 关闭父级页面 (通常是 SettingsView)
                        dismissParent?()
                        
                        // 5. 再次延迟以确保页面完全关闭，然后切换数据源
                        // 这样可以避免在视图销毁过程中更新数据导致的状态冲突
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("AccountListView: Switching account context to \(profile.nickname)")
                            
                            // 6. 切换账号 (触发 RootView 重建)
                            // 这将发送 Notification，导致 App 根视图重置
                            viewModel.switchToAccount(profile.id)
                            
                            // 7. 刷新列表状态 (虽然页面已关闭，但保持状态一致性)
                            viewModel.refreshAccounts()
                            
                            // 8. 通知回调
                            onAccountSwitch?()
                        }
                    }
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