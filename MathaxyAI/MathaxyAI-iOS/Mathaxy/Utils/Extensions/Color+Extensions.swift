//
//  Color+Extensions.swift
//  Mathaxy
//
//  颜色扩展
//  定义应用使用的颜色
//

import SwiftUI

// MARK: - 颜色扩展
extension Color {
    
    // MARK: - 主色调
    
    /// 星空蓝（主背景色）
    static let spaceBlue = Color(hex: "#1A1A2E")
    
    /// 荧光黄（强调色）
    static let starlightYellow = Color(hex: "#FFD700")
    
    // MARK: - 辅助色
    
    /// 星云紫
    static let nebulaPurple = Color(hex: "#4B0082")
    
    /// 星尘紫（用于游戏元素）
    static let stardustPurple = Color(hex: "#6A0DAD")
    
    /// 银河粉
    static let galaxyPink = Color(hex: "#FF6B9D")
    
    /// 彗星白
    static let cometWhite = Color(hex: "#FFFFFF")
    
    /// 警告红
    static let alertRed = Color(hex: "#FF4444")
    
    /// 成功绿
    static let successGreen = Color(hex: "#00C851")
    
    /// 错误红
    static let errorRed = Color(hex: "#DC3545")
    
    /// 禁用灰
    static let disabledGray = Color(hex: "#6C757D")
    
    /// 卡片背景色
    static let cardBackground = spaceBlue.opacity(0.8)
    
    // MARK: - 渐变色
    
    /// 银河背景渐变
    static let galaxyGradient = LinearGradient(
        colors: [spaceBlue, Color(hex: "#2D2D44"), spaceBlue],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// 按钮渐变
    static let buttonGradient = LinearGradient(
        colors: [starlightYellow, Color(hex: "#FFA500")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// 勋章渐变
    static let badgeGradient = LinearGradient(
        colors: [starlightYellow, Color(hex: "#FFA500"), Color(hex: "#FF8C00")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - 初始化方法（十六进制）
    
    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制颜色字符串（如 "#FF0000" 或 "FF0000"）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - 颜色调整方法
    
    /// 调整亮度
    /// - Parameter amount: 调整量（-1.0 到 1.0）
    /// - Returns: 调整后的颜色
    func adjustBrightness(by amount: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        let newBrightness = max(0, min(1, brightness + amount))
        
        return Color(
            hue: hue,
            saturation: saturation,
            brightness: newBrightness,
            opacity: alpha
        )
    }
    
    /// 调整透明度
    /// - Parameter opacity: 新的透明度（0.0 到 1.0）
    /// - Returns: 调整后的颜色
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
}

// MARK: - 颜色主题
struct AppColors {
    
    // MARK: - 背景颜色
    static let primaryBackground = Color.spaceBlue
    static let secondaryBackground = Color.spaceBlue.adjustBrightness(by: 0.1)
    static let cardBackground = Color.nebulaPurple.opacity(0.3)
    
    // MARK: - 文字颜色
    static let primaryText = Color.cometWhite
    static let secondaryText = Color.cometWhite.opacity(0.7)
    static let accentText = Color.starlightYellow
    static let darkText = Color.spaceBlue
    
    // MARK: - 按钮颜色
    static let primaryButton = Color.starlightYellow
    static let secondaryButton = Color.cometWhite
    static let dangerButton = Color.alertRed
    
    // MARK: - 状态颜色
    static let success = Color.successGreen
    static let error = Color.errorRed
    static let warning = Color.starlightYellow
    static let info = Color.galaxyPink
    
    // MARK: - 游戏相关颜色
    static let timerColor = Color.alertRed
    static let correctAnswer = Color.successGreen
    static let wrongAnswer = Color.errorRed
    static let questionText = Color.cometWhite
}
