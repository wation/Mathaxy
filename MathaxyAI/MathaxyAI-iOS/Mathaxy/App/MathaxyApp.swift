//
//  MathaxyApp.swift
//  Mathaxy
//
//  应用入口
//  定义应用的主入口和根视图
//

import SwiftUI

// MARK: - 通知名称
extension Notification.Name {
    static let gameDidComplete = Notification.Name("gameDidComplete")
}

// MARK: - 应用入口
@main
struct MathaxyApp: App {
    
    // MARK: - 应用状态
    @StateObject private var localizationService = LocalizationService.shared
    @StateObject private var storageService = StorageService.shared
    
    // MARK: - 应用主体
    var body: some Scene {
        WindowGroup {
            // 根视图：根据是否首次启动显示登录页或首页
            RootView()
                .environmentObject(localizationService)
                .environmentObject(storageService)
        }
    }
    
    // MARK: - 应用初始化
    init() {
        // 初始化应用
        setupApplication()
    }
    
    // MARK: - 应用设置
    private func setupApplication() {
        // 检查是否首次启动
        if StorageService.shared.isFirstLaunch() {
            // 首次启动，标记为已启动
            StorageService.shared.markAsLaunched()
            
            print("Mathaxy: 首次启动")
        } else {
            print("Mathaxy: 非首启动")
        }
        
        // 初始化服务
        setupServices()
    }
    
    // MARK: - 初始化服务
    private func setupServices() {
        // 预加载广告
        if AdConfig.preloadAdsOnLaunch {
            AdService.shared.preloadRewardedAd()
        }
        
        // 更新登录记录
        _ = LoginTrackingService.shared.updateLoginRecord()
    }
}

// MARK: - 根视图
struct RootView: View {
    
    // MARK: - 应用状态
    @EnvironmentObject private var storageService: StorageService
    
    // MARK: - 视图状态
    @State private var isLoggedIn = false
    @State private var userProfile: UserProfile?
    @State private var refreshID = UUID()
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoggedIn, let profile = userProfile {
                // 已登录，显示首页
                HomeView(userProfile: profile)
                    .id(refreshID)
            } else {
                // 未登录，显示登录页
                LoginView(onLoginSuccess: { profile in
                    handleLoginSuccess(profile)
                })
            }
        }
        .onAppear {
            loadUserProfile()
            setupNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameDidComplete)) { _ in
            // 游戏完成，重新加载用户资料
            if let profile = storageService.loadUserProfile() {
                userProfile = profile
                refreshID = UUID()
            }
        }
    }
    
    // MARK: - 处理登录成功
    private func handleLoginSuccess(_ profile: UserProfile) {
        userProfile = profile
        isLoggedIn = true
    }
    
    // MARK: - 加载用户资料
    private func loadUserProfile() {
        if let profile = storageService.loadUserProfile() {
            userProfile = profile
            isLoggedIn = true
        } else {
            // 没有用户资料，显示登录页
            isLoggedIn = false
        }
    }
    
    // MARK: - 监听通知
    private func setupNotifications() {
        // 使用onReceive来监听通知
    }
}
