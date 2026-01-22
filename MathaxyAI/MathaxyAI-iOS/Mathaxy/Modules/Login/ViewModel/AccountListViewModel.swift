//
//  AccountListViewModel.swift
//  Mathaxy
//
//  账号列表视图模型
//  管理账号列表数据和切换逻辑
//

import Foundation
import SwiftUI

// MARK: - 账号列表视图模型
class AccountListViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    
    // MARK: - 视图状态
    @Published var accounts: [AccountInfo]
    @Published var showAddAccount = false
    
    // MARK: - 初始化
    init() {
        self.accounts = storageService.getAccountsList()
    }
    
    // MARK: - 刷新账号列表
    func refreshAccounts() {
        accounts = storageService.getAccountsList()
    }
    
    // MARK: - 切换账号
    func switchToAccount(_ accountId: UUID) {
        // 设置当前账号ID
        storageService.setCurrentAccountId(accountId)
        
        // 更新最后登录时间
        storageService.updateAccountLastLogin(at: accountId)
        
        // 发送账号切换通知
        NotificationCenter.default.post(name: .accountSwitched, object: nil)
    }
    
    // MARK: - 删除账号
    func deleteAccount(_ accountId: UUID) {
        storageService.deleteAccount(accountId)
        refreshAccounts()
    }
    
    // MARK: - 添加新账号
    func addNewAccount() {
        showAddAccount = true
    }
    
    // MARK: - 准备添加新账号
    func prepareForAddAccount() {
        // 退出当前登录状态
        storageService.logout()
        
        // 发送账号切换通知 (通知 RootView 刷新，此时无用户登录，会自动显示 LoginView)
        NotificationCenter.default.post(name: .accountSwitched, object: nil)
    }

    // MARK: - 获取当前账号
    func getCurrentAccountId() -> UUID? {
        return storageService.getCurrentAccountId()
    }
    
    // MARK: - 检查是否为当前账号
    func isCurrentAccount(_ accountId: UUID) -> Bool {
        return getCurrentAccountId() == accountId
    }
}
