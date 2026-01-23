//
//  QDesignTokens.swift
//  Mathaxy
//
//  Q版设计系统 Tokens（可复用基础设施）
//  基于 plans/Q版设计系统Tokens.md 规范实现
//

import SwiftUI

// MARK: - QAsset（图片资源 Token）
/// Q版图片资源统一命名规范
/// 所有资源名与 Assets.xcassets 中的 imageset 名称一一对应
enum QAsset {
    // MARK: - 背景资源
    enum bg {
        static let login = "login_background_qstyle"
        static let home = "home_background_qstyle"
        static let game = "game_background_qstyle"
        static let levelSelect = "QStyleUI/8._关卡选择页背景"
        static let achievement = "achievement_background_qstyle"
        static let settings = "settings_background_qstyle"
        static let result = "game_over_background_qstyle"
    }
    
    // MARK: - 按钮资源
    enum button {
        static let primary = "primary_button_qstyle"
        static let secondary = "secondary_button_qstyle"
        static let level = "QStyleUI/19._Q版关卡按钮样式"
        static let answer = "answer_button_qstyle"
    }
    
    // MARK: - 组件资源
    enum component {
        static let progressBar = "progress_bar_qstyle"
        static let timer = "timer_qstyle"
        static let popupBg = "popup_background_qstyle"
        static let badgeStyle = "badge_style_qstyle"
    }
    
    // MARK: - 反馈资源
    enum feedback {
        static let correct = "correct_feedback_qstyle"
        static let incorrect = "incorrect_feedback_qstyle"
    }
    
    // MARK: - 弹窗资源
    enum popup {
        static let achievementUnlock = "achievement_unlock_popup_qstyle"
    }
    
    // MARK: - 角色资源
    enum character {
        static let numberSprite = "number_sprite_qstyle"
    }
    
    // MARK: - 装饰资源
    enum decoration {
        static let star = "QStyleUI/13._Q版星星装饰"
        static let planet = "QStyleUI/14._Q版星球装饰"
        static let mathSymbol = "QStyleUI/15._Q版数学符号装饰"
    }
    
    // MARK: - 其他资源
    static let appIcon = "app_icon_qstyle"
    static let launchScreen = "launch_screen_qstyle"
    static let guideScreen = "guide_screen_qstyle"
}

// MARK: - QColor（颜色 Token）
/// Q版颜色规范
/// QStyle 以图片为主，颜色主要用于：文字、遮罩、状态（danger/success）、卡片内部浅色区域
enum QColor {
    // MARK: - 文字颜色
    enum text {
        /// 深色背景上的主文字（白色）
        static let onDarkPrimary = Color(hex: 0xFFFFFF)
        /// 深色背景上的次文字（半透明白色）
        static let onDarkSecondary = Color.white.opacity(0.75)
        /// 浅色面板（弹窗/奖状）上的主文字（深蓝色）
        static let onLightPrimary = Color(hex: 0x1A1A2E)
    }
    
    // MARK: - 品牌色
    enum brand {
        /// 强调数字、关键指标（金黄色）
        static let accent = Color(hex: 0xFFD700)
    }
    
    // MARK: - 状态色
    enum state {
        /// 错误/危险操作（红色）
        static let danger = Color(hex: 0xFF4444)
        /// 成功/正确状态（绿色）
        static let success = Color(hex: 0x00C851)
    }
    
    // MARK: - 遮罩色
    enum overlay {
        /// 弹窗遮罩（半透明黑色）
        static let scrim = Color.black.opacity(0.55)
    }
}

// MARK: - QFont（字体 Token）
/// Q版字体规范
/// 字体以"语义"命名，数值参考现有规范；QStyle 不要求更换字体家族
enum QFont {
    /// 页面主标题、关键结果（如通关）
    static let displayHero = Font.system(size: 36, weight: .bold)
    /// 页面标题（设置/成就/关卡选择）
    static let titlePage = Font.system(size: 28, weight: .bold)
    /// 用户昵称（更卡通的圆润风格）
    static let nickname = Font.system(size: 30, weight: .heavy, design: .rounded)
    /// 弹窗标题、卡片标题
    static let titleSection = Font.system(size: 22, weight: .bold)
    /// 正文
    static let body = Font.system(size: 18, weight: .regular)
    /// 按钮文字（主/次）
    static let bodyEmphasis = Font.system(size: 18, weight: .semibold)
    /// 辅助说明、版本号
    static let caption = Font.system(size: 12, weight: .medium)
    
    // MARK: - 游戏专用字体
    enum game {
        /// GamePlay 题目数字
        static let questionNumber = Font.system(size: 56, weight: .bold)
        /// + / = 运算符
        static let mathOperator = Font.system(size: 42, weight: .bold)
        /// 顶部计时器数字（叠在 timer 图上）
        static let timer = Font.system(size: 24, weight: .bold)
    }
}

// MARK: - QRadius（圆角 Token）
/// Q版圆角规范
/// 当使用图片底时，圆角主要用于：弹窗容器、卡片容器、非图片的补充面板
enum QRadius {
    /// 主/次按钮容器（若有 hit area 包裹）
    static let button: CGFloat = 16
    /// 卡片、题目面板
    static let card: CGFloat = 20
    /// 弹窗容器
    static let popup: CGFloat = 24
    /// 小标签、统计小块
    static let chip: CGFloat = 12
}

// MARK: - QStroke（描边 Token）
/// Q版描边规范
/// 当使用图片底时，描边主要用于：弹窗容器、卡片容器、非图片的补充面板
enum QStroke {
    /// 细描边（卡片边界）
    static let thin: CGFloat = 1
    /// 主要描边（题目面板/次按钮边框等）
    static let medium: CGFloat = 2
    /// 强强调（奖状边框/重点面板）
    static let thick: CGFloat = 3
}

// MARK: - QShadow（阴影 Token）
/// Q版阴影规范
/// 当使用图片底时，阴影主要用于：弹窗容器、卡片容器、非图片的补充面板
enum QShadow {
    /// 按钮轻投影
    static let elevation1 = (color: Color.black.opacity(0.18), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
    /// 弹窗/浮层
    static let elevation2 = (color: Color.black.opacity(0.25), radius: CGFloat(10), x: CGFloat(0), y: CGFloat(6))
}

// MARK: - QSpace（间距 Token）
/// Q版间距规范
enum QSpace {
    /// 图标与文字的小间距
    static let xs: CGFloat = 6
    /// 常用小间距
    static let s: CGFloat = 10
    /// 组件默认间距
    static let m: CGFloat = 16
    /// 页面内主要间距
    static let l: CGFloat = 20
    /// 大区块分隔
    static let xl: CGFloat = 30
    /// 页面左右 padding
    static let pagePadding: CGFloat = 20
}

// MARK: - QSize（尺寸 Token）
/// Q版尺寸规范
enum QSize {
    // MARK: - 按钮尺寸
    enum button {
        /// 主按钮（参考 QStyle Home 实现）
        static let primaryHeight: CGFloat = 142 // 2848px/20，保证五角星完整显示，适配大图
        /// 次按钮
        static let secondaryHeight: CGFloat = 56
        /// 关卡按钮（建议方形或近方形）
        static let level: CGFloat = 140
        /// 答案按钮（方形）
        static let answer: CGFloat = 72
    }
    
    // MARK: - 其他尺寸
    /// 导航图标
    static let iconNav: CGFloat = 24
    /// 角色/头像容器
    static let avatar: CGFloat = 120
    /// 弹窗基准宽度（可自适应）
    static let popupWidth: CGFloat = 320
}

// MARK: - Color Extension for Hex
/// Color 扩展，支持十六进制颜色值初始化
extension Color {
    /// 通过十六进制值创建 Color
    /// - Parameter hex: 十六进制颜色值（例如 0xFFFFFF）
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
