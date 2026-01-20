//
//  LoginViewModel.swift
//  Mathaxy
//
//  登录模块视图模型
//  负责处理登录逻辑
//

import Foundation
import SwiftUI

// MARK: - 登录视图模型
class LoginViewModel: ObservableObject {
    
    // MARK: - 服务
    private let storageService = StorageService.shared
    private let loginTrackingService = LoginTrackingService.shared
    
    // MARK: - 视图状态
    @Published var isGuestLogin = false
    @Published var isParentBind = false
    @Published var nickname = ""
    @Published var isSaving = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // MARK: - 登录完成回调
    var onLoginSuccess: ((UserProfile) -> Void)?
    
    // MARK: - 游客登录
    
    /// 游客登录
    func guestLogin() {
        isSaving = true
        errorMessage = ""
        showError = false
        
        // 生成游客昵称
        let guestNickname = UserProfile.generateGuestNickname()
        
        // 创建用户资料
        let userProfile = UserProfile(nickname: guestNickname)
        
        // 保存用户资料
        storageService.saveUserProfile(userProfile)
        
        // 播放音效
        SoundService.shared.playButtonClickSound()
        
        // 延迟一秒后回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isSaving = false
            self?.onLoginSuccess?(userProfile)
        }
    }
    
    // MARK: - 家长辅助绑定
    
    /// 家长辅助绑定
    func parentBind() {
        // 验证昵称
        guard validateNickname() else {
            return
        }
        
        isSaving = true
        errorMessage = ""
        showError = false
        
        // 创建用户资料
        let userProfile = UserProfile(nickname: nickname)
        
        // 保存用户资料
        storageService.saveUserProfile(userProfile)
        
        // 播放音效
        SoundService.shared.playButtonClickSound()
        
        // 延迟一秒后回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isSaving = false
            self?.onLoginSuccess?(userProfile)
        }
    }
    
    // MARK: - 验证昵称
    
    /// 验证昵称
    /// - Returns: 是否有效
    func validateNickname() -> Bool {
        // 检查是否为空
        guard !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = LocalizedKeys.enterNickname.localized
            showError = true
            return false
        }
        
        // 检查长度（1-20个字符）
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedNickname.count >= 1 && trimmedNickname.count <= 20 else {
            errorMessage = "昵称长度应为1-20个字符"
            showError = true
            return false
        }
        
        return true
    }
    
    // MARK: - 切换登录方式
    
    /// 切换到游客登录
    func switchToGuestLogin() {
        isGuestLogin = true
        isParentBind = false
        nickname = ""
        errorMessage = ""
        showError = false
    }
    
    /// 切换到家长辅助绑定
    func switchToParentBind() {
        isGuestLogin = false
        isParentBind = true
        errorMessage = ""
        showError = false
    }
    
    // MARK: - 清除错误
    
    /// 清除错误信息
    func clearError() {
        errorMessage = ""
        showError = false
    }
}
