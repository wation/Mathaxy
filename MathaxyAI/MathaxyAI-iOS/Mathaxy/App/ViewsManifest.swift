import SwiftUI

// MARK: - Views Manifest
// 此文件用于帮助Xcode识别跨模块的视图
// This file helps Xcode recognize views across modules

// 导入游戏模块视图
import Foundation

// Forward declarations for views
// These are needed for Xcode to properly index the views

#if !SWIFT_PACKAGE

/// 登录视图 - 从Login模块
/// 此视图定义在: Modules/Login/View/LoginView.swift
struct LoginViewManifest {
    static func createView() -> some View {
        Text("LoginView")
    }
}

/// 首页视图 - 从Home模块
/// 此视图定义在: Modules/Home/View/HomeView.swift
struct HomeViewManifest {
    static func createView(userProfile: UserProfile) -> some View {
        Text("HomeView")
    }
}

/// 关卡选择视图 - 从Game模块
/// 此视图定义在: Modules/Game/View/LevelSelectView.swift
struct LevelSelectViewManifest {
    static func createView(userProfile: UserProfile) -> some View {
        Text("LevelSelectView")
    }
}

/// 游戏视图 - 从Game模块
/// 此视图定义在: Modules/Game/View/GameView.swift
struct GameViewManifest {
    static func createView(level: Int) -> some View {
        Text("GameView")
    }
}

/// 游戏玩法视图 - 从Game模块
/// 此视图定义在: Modules/Game/View/GamePlayView.swift
struct GamePlayViewManifest {
    static func createView(level: Int) -> some View {
        Text("GamePlayView")
    }
}

/// 结果视图 - 从Game模块
/// 此视图定义在: Modules/Game/View/ResultView.swift
struct ResultViewManifest {
    static func createView(gameSession: GameSession) -> some View {
        Text("ResultView")
    }
}

/// 成就视图 - 从Achievement模块  
/// 此视图定义在: Modules/Achievement/View/AchievementView.swift
struct AchievementViewManifest {
    static func createView(userProfile: UserProfile) -> some View {
        Text("AchievementView")
    }
}

/// 勋章收藏视图 - 从Achievement模块
/// 此视图定义在: Modules/Achievement/View/BadgeCollectionView.swift
struct BadgeCollectionViewManifest {
    static func createView(userProfile: UserProfile) -> some View {
        Text("BadgeCollectionView")
    }
}

/// 奖状视图 - 从Achievement模块
/// 此视图定义在: Modules/Achievement/View/CertificateView.swift
struct CertificateViewManifest {
    static func createView(gameSession: GameSession) -> some View {
        Text("CertificateView")
    }
}

/// 设置视图 - 从Settings模块
/// 此视图定义在: Modules/Settings/View/SettingsView.swift
struct SettingsViewManifest {
    static func createView() -> some View {
        Text("SettingsView")
    }
}

#endif
