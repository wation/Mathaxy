//
//  View+Extensions.swift
//  Mathaxy
//
//  View扩展
//  提供常用的View修饰符和工具方法
//

import SwiftUI

// MARK: - View扩展
extension View {
    
    // MARK: - 条件修饰符
    
    /// 条件应用修饰符
    /// - Parameters:
    ///   - condition: 条件
    ///   - modifier: 修饰符
    /// - Returns: 应用修饰符后的View
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// 条件应用不同的修饰符
    /// - Parameters:
    ///   - condition: 条件
    ///   - trueModifier: 条件为真时的修饰符
    ///   - falseModifier: 条件为假时的修饰符
    /// - Returns: 应用修饰符后的View
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueModifier: (Self) -> TrueContent,
        else falseModifier: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueModifier(self)
        } else {
            falseModifier(self)
        }
    }
    
    // MARK: - 隐藏和显示
    
    /// 根据条件隐藏View
    /// - Parameter isHidden: 是否隐藏
    /// - Returns: 隐藏或显示的View
    @ViewBuilder
    func hidden(_ isHidden: Bool) -> some View {
        if !isHidden {
            self
        }
    }
    
    /// 根据条件显示View
    /// - Parameter isShown: 是否显示
    /// - Returns: 显示或隐藏的View
    @ViewBuilder
    func shown(_ isShown: Bool) -> some View {
        if isShown {
            self
        }
    }
    
    // MARK: - 圆角和阴影
    
    /// 添加圆角和阴影
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - shadowColor: 阴影颜色
    ///   - shadowRadius: 阴影半径
    ///   - shadowOffset: 阴影偏移
    /// - Returns: 应用圆角和阴影的View
    func cornerRadius(
        _ radius: CGFloat,
        shadowColor: Color = .black.opacity(0.2),
        shadowRadius: CGFloat = 4,
        shadowOffset: CGSize = CGSize(width: 0, height: 2)
    ) -> some View {
        self
            .background(Color.clear)
            .cornerRadius(radius)
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset.width, y: shadowOffset.height)
    }
    
    /// 添加卡片样式
    /// - Returns: 应用卡片样式的View
    func cardStyle() -> some View {
        self
            .background(AppColors.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.starlightYellow, lineWidth: 2)
            )
    }
    
    // MARK: - 按钮样式
    
    /// 应用主按钮样式
    /// - Returns: 应用主按钮样式的View
    func primaryButtonStyle() -> some View {
        self
            .background(Color.buttonGradient)
            .foregroundColor(AppColors.darkText)
            .font(.system(size: 18, weight: .semibold))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    /// 应用次按钮样式
    /// - Returns: 应用次按钮样式的View
    func secondaryButtonStyle() -> some View {
        self
            .background(Color.clear)
            .foregroundColor(Color.starlightYellow)
            .font(.system(size: 18, weight: .semibold))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.starlightYellow, lineWidth: 2)
            )
    }
    
    /// 应用答题按钮样式
    /// - Returns: 应用答题按钮样式的View
    func answerButtonStyle() -> some View {
        self
            .background(Color.nebulaPurple)
            .foregroundColor(Color.cometWhite)
            .font(.system(size: 28, weight: .semibold))
            .frame(width: 72, height: 72)
            .cornerRadius(12)
    }
    
    // MARK: - 动画效果
    
    /// 添加缩放动画
    /// - Parameters:
    ///   - isPressed: 是否按下
    ///   - scale: 缩放比例
    /// - Returns: 应用缩放动画的View
    func scaleEffect(isPressed: Bool, scale: CGFloat = 0.95) -> some View {
        self
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
    
    /// 添加淡入动画
    /// - Parameter delay: 延迟时间
    /// - Returns: 应用淡入动画的View
    func fadeInAnimation(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.3).delay(delay)) {
                    // 需要使用状态变量来控制透明度
                }
            }
    }
    
    /// 添加滑入动画
    /// - Parameters:
    ///   - offset: 偏移量
    ///   - delay: 延迟时间
    /// - Returns: 应用滑入动画的View
    func slideInAnimation(offset: CGFloat = 50, delay: Double = 0) -> some View {
        self
            .offset(y: offset)
            .opacity(0)
            .onAppear {
                withAnimation(.easeOut(duration: 0.4).delay(delay)) {
                    // 需要使用状态变量来控制偏移和透明度
                }
            }
    }
    
    // MARK: - 安全区域
    
    /// 添加底部安全区域
    /// - Returns: 添加底部安全区域的View
    func addBottomSafeArea() -> some View {
        let bottomInset = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first?.safeAreaInsets.bottom ?? 0
        return self.padding(.bottom, bottomInset)
    }
    
    /// 添加顶部安全区域
    /// - Returns: 添加顶部安全区域的View
    func addTopSafeArea() -> some View {
        let topInset = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first?.safeAreaInsets.top ?? 0
        return self.padding(.top, topInset)
    }
    
    // MARK: - 触摸反馈
    
    /// 添加触摸反馈（带音效）
    /// - Parameter action: 触摸动作
    /// - Returns: 添加触摸反馈的View
    func onTapWithSound(perform action: @escaping () -> Void) -> some View {
        return self
            .onTapGesture {
                SoundService.shared.playButtonClickSound()
                action()
            }
    }
    
    // MARK: - 设备适配
    
    /// 根据设备类型调整
    /// - Parameters:
    ///   - iPhone: iPhone样式
    ///   - iPad: iPad样式
    /// - Returns: 根据设备调整后的View
    @ViewBuilder
    func adaptive<IPhoneContent: View, IPadContent: View>(
        iPhone: (Self) -> IPhoneContent,
        iPad: (Self) -> IPadContent
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            iPad(self)
        } else {
            iPhone(self)
        }
    }
    
    /// 检查是否为iPad
    var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 检查是否为iPhone
    var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

// MARK: - 自定义修饰符

/// 隐藏键盘修饰符
struct HideKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

extension View {
    /// 隐藏键盘
    func hideKeyboard() -> some View {
        self.modifier(HideKeyboardModifier())
    }
}

/// 骨架屏修饰符
struct SkeletonModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 100)
                            .offset(x: -100)
                            .animation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false),
                                value: UUID()
                            )
                    )
            } else {
                content
            }
        }
    }
}

extension View {
    /// 添加骨架屏效果
    /// - Parameter isLoading: 是否正在加载
    /// - Returns: 添加骨架屏效果的View
    func skeleton(isLoading: Bool) -> some View {
        self.modifier(SkeletonModifier(isLoading: isLoading))
    }
}
