//
//  QStyleComponents.swift
//  Mathaxy
//
//  Q版基础组件与 ViewModifiers
//  基于 plans/Q版设计系统Tokens.md 规范实现
//

import SwiftUI

// MARK: - QBackground（统一背景容器）
/// Q版统一背景容器
/// 自动根据页面类型选择对应的 QStyle 背景图
struct QBackground<Content: View>: View {
    /// 页面类型枚举
    enum PageType {
        case login
        case home
        case game
        case levelSelect
        case achievement
        case settings
        case result
    }
    
    let pageType: PageType
    let content: Content
    
    init(pageType: PageType, @ViewBuilder content: () -> Content) {
        self.pageType = pageType
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // 背景图（全屏填充）
            Image(backgroundAssetName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // 内容层
            content
                .padding(.horizontal, QSpace.pagePadding)
        }
    }
    
    /// 根据页面类型获取背景资源名
    private var backgroundAssetName: String {
        switch pageType {
        case .login:
            return QAsset.bg.login
        case .home:
            return QAsset.bg.home
        case .game:
            return QAsset.bg.game
        case .levelSelect:
            return QAsset.bg.levelSelect
        case .achievement:
            return QAsset.bg.achievement
        case .settings:
            return QAsset.bg.settings
        case .result:
            return QAsset.bg.result
        }
    }
}

// MARK: - QCardStyle（卡片样式）
/// Q版卡片样式 ViewModifier
/// 用于弹窗容器、卡片容器、非图片的补充面板
struct QCardStyle: ViewModifier {
    let radius: CGFloat
    let stroke: CGFloat
    let shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat)
    
    init(radius: CGFloat = QRadius.card,
         stroke: CGFloat = QStroke.medium,
         shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = QShadow.elevation2) {
        self.radius = radius
        self.stroke = stroke
        self.shadow = shadow
    }
    
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.white.opacity(0.3), lineWidth: stroke)
            )
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// MARK: - QPopupStyle（弹窗样式）
/// Q版弹窗样式 ViewModifier
/// 用于退出确认、重置确认、勋章详情等弹窗
/// 包含出现/消失的 spring 动画（从下/淡入 + scale）
struct QPopupStyle: ViewModifier {
    @State private var isPresented = false
    
    func body(content: Content) -> some View {
        ZStack {
            // 遮罩层（淡入淡出）
            QColor.overlay.scrim
                .ignoresSafeArea()
                .opacity(isPresented ? 1.0 : 0.0)
            
            // 弹窗内容（spring 动画：从下/淡入 + scale）
            content
                .modifier(QCardStyle(radius: QRadius.popup))
                .padding(QSpace.l)
                .scaleEffect(isPresented ? 1.0 : 0.8)
                .opacity(isPresented ? 1.0 : 0.0)
                .offset(y: isPresented ? 0 : 20)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: isPresented)
        }
        .onAppear {
            // 弹窗出现时触发动画
            withAnimation {
                isPresented = true
            }
        }
    }
}

// MARK: - QButtonStyle（按钮样式）
/// Q版按钮样式 ViewModifier
/// 用于主/次按钮的统一样式
struct QButtonStyle: ViewModifier {
    enum ButtonType {
        case primary
        case secondary
        case destructive
    }
    
    let buttonType: ButtonType
    let isPressed: Bool
    let isDisabled: Bool
    
    init(buttonType: ButtonType = .primary, isPressed: Bool = false, isDisabled: Bool = false) {
        self.buttonType = buttonType
        self.isPressed = isPressed
        self.isDisabled = isDisabled
    }
    
    func body(content: Content) -> some View {
        content
            .font(QFont.bodyEmphasis)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(buttonBackground)
            .cornerRadius(QRadius.button)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .shadow(color: QShadow.elevation1.color, radius: QShadow.elevation1.radius, x: QShadow.elevation1.x, y: QShadow.elevation1.y)
    }
    
    /// 按钮高度
    private var buttonHeight: CGFloat {
        switch buttonType {
        case .primary:
            return QSize.button.primaryHeight
        case .secondary, .destructive:
            return QSize.button.secondaryHeight
        }
    }
    
    /// 文字颜色
    private var textColor: Color {
        switch buttonType {
        case .primary, .secondary:
            return QColor.text.onLightPrimary
        case .destructive:
            return QColor.state.danger
        }
    }
    
    /// 按钮背景
    @ViewBuilder
    private var buttonBackground: some View {
        switch buttonType {
        case .primary:
            Image(QAsset.button.primary)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .secondary:
            Image(QAsset.button.secondary)
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .destructive:
            Color.white
        }
    }
}

// MARK: - QPrimaryButton（主要按钮）
/// Q版主要按钮组件
/// 用于主要操作，如"开始游戏"、"确认"等
struct QPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: QColor.text.onLightPrimary))
                } else {
                    Text(title)
                }
            }
        }
        .modifier(QButtonStyle(buttonType: .primary, isPressed: isPressed, isDisabled: isDisabled || isLoading))
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - QSecondaryButton（次要按钮）
/// Q版次要按钮组件
/// 用于次要操作，如"取消"、"返回"等
struct QSecondaryButton: View {
    let title: String
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: QColor.text.onLightPrimary))
                } else {
                    Text(title)
                }
            }
        }
        .modifier(QButtonStyle(buttonType: .secondary, isPressed: isPressed, isDisabled: isDisabled || isLoading))
        .disabled(isDisabled || isLoading)
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - QPopupContainer（弹窗容器）
/// Q版弹窗容器组件
/// 用于显示统一样式的弹窗内容
struct QPopupContainer<Content: View>: View {
    let title: String
    let content: Content
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?
    
    init(
        title: String,
        @ViewBuilder content: () -> Content,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        onPrimary: @escaping () -> Void,
        onSecondary: (() -> Void)? = nil
    ) {
        self.title = title
        self.content = content()
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryButtonTitle = secondaryButtonTitle
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
    }
    
    var body: some View {
        VStack(spacing: QSpace.m) {
            // 标题
            Text(title)
                .font(QFont.titleSection)
                .foregroundColor(QColor.text.onLightPrimary)
                .multilineTextAlignment(.center)
            
            // 内容
            content
                .foregroundColor(QColor.text.onLightPrimary)
            
            // 按钮区域
            VStack(spacing: QSpace.s) {
                QPrimaryButton(title: primaryButtonTitle, action: onPrimary)
                
                if let secondaryTitle = secondaryButtonTitle, let secondaryAction = onSecondary {
                    QSecondaryButton(title: secondaryTitle, action: secondaryAction)
                }
            }
        }
        .padding(QSpace.l)
        .frame(width: QSize.popupWidth)
        .modifier(QCardStyle(radius: QRadius.popup))
    }
}

// MARK: - QProgressBar（进度条）
/// Q版进度条组件
/// 用于显示游戏进度、关卡进度等
struct QProgressBar: View {
    let progress: Double // 0.0 ~ 1.0
    let height: CGFloat
    
    init(progress: Double, height: CGFloat = 24) {
        self.progress = max(0.0, min(1.0, progress))
        self.height = height
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 背景图
            Image(QAsset.component.progressBar)
                .resizable()
                .frame(height: height)
            
            // 进度填充
            GeometryReader { geometry in
                Rectangle()
                    .fill(QColor.brand.accent)
                    .frame(width: geometry.size.width * progress, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: height / 2))
            }
        }
    }
}

// MARK: - QTimerBadge（计时器徽章）
/// Q版计时器徽章组件
/// 用于显示游戏倒计时
struct QTimerBadge: View {
    let remainingTime: Int // 剩余秒数
    let totalTime: Int // 总秒数
    
    /// 是否紧急状态（剩余时间小于10秒）
    private var isUrgent: Bool {
        remainingTime < 10
    }
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 1.0
    
    init(remainingTime: Int, totalTime: Int) {
        self.remainingTime = remainingTime
        self.totalTime = totalTime
    }
    
    var body: some View {
        ZStack {
            // 计时器背景图
            Image(QAsset.component.timer)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
            
            // 时间数字
            Text("\(remainingTime)")
                .font(QFont.game.timer)
                .foregroundColor(isUrgent ? QColor.state.danger : QColor.text.onDarkPrimary)
                .contentTransition(.numericText())
        }
        .overlay(
            Group {
                if isUrgent {
                    // 紧急状态时的脉冲效果
                    Circle()
                        .stroke(QColor.state.danger.opacity(0.5), lineWidth: 2)
                        .scaleEffect(pulseScale)
                        .opacity(pulseOpacity)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: false),
                            value: pulseScale
                        )
                }
            }
        )
        .onAppear {
            if isUrgent {
                withAnimation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: false)
                ) {
                    pulseScale = 1.5
                    pulseOpacity = 0.0
                }
            }
        }
    }
}

// MARK: - QLevelButton（关卡按钮）
/// Q版关卡按钮组件
/// 用于关卡选择页面的关卡按钮
/// 包含按压反馈动效：scale + opacity + shadow 变化
struct QLevelButton: View {
    enum LevelState {
        case completed
        case current
        case locked
    }
    
    let levelNumber: Int
    let state: LevelState
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    init(levelNumber: Int, state: LevelState = .locked, onTap: @escaping () -> Void) {
        self.levelNumber = levelNumber
        self.state = state
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 关卡按钮背景图
                Image(QAsset.button.level)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: QSize.button.level, height: QSize.button.level)
                    .opacity(state == .locked ? 0.5 : 1.0)
                
                // 关卡数字
                Text("\(levelNumber)")
                    .font(QFont.displayHero)
                    .foregroundColor(state == .locked ? QColor.text.onDarkSecondary : QColor.text.onDarkPrimary)
                
                // 完成状态图标
                if state == .completed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(QColor.state.success)
                        .offset(x: 30, y: -30)
                }
                
                // 锁定状态图标
                if state == .locked {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(QColor.text.onDarkSecondary)
                }
            }
            // 统一按压反馈动效：scale + opacity + shadow 变化
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .shadow(
                color: QShadow.elevation1.color,
                radius: isPressed ? QShadow.elevation1.radius * 0.5 : QShadow.elevation1.radius,
                x: QShadow.elevation1.x,
                y: isPressed ? QShadow.elevation1.y * 0.5 : QShadow.elevation1.y
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(state == .locked)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - QAnswerOptionButton（答案选项按钮）
/// Q版答案选项按钮组件
/// 用于游戏页面的答案输入
/// 包含按压反馈动效：scale + opacity + shadow 变化
struct QAnswerOptionButton: View {
    enum AnswerState {
        case normal
        case selected
        case correct
        case incorrect
    }
    
    let value: String
    let state: AnswerState
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    init(value: String, state: AnswerState = .normal, onTap: @escaping () -> Void) {
        self.value = value
        self.state = state
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 答案按钮背景图
                Image(QAsset.button.answer)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: QSize.button.answer, height: QSize.button.answer)
                    .overlay(
                        Group {
                            if state == .correct {
                                Color.green.opacity(0.3)
                            } else if state == .incorrect {
                                Color.red.opacity(0.3)
                            } else if state == .selected {
                                Color.blue.opacity(0.3)
                            }
                        }
                    )
                
                // 答案值
                Text(value)
                    .font(QFont.game.questionNumber)
                    .foregroundColor(QColor.text.onDarkPrimary)
            }
            // 统一按压反馈动效：scale + opacity + shadow 变化
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .shadow(
                color: QShadow.elevation1.color,
                radius: isPressed ? QShadow.elevation1.radius * 0.5 : QShadow.elevation1.radius,
                x: QShadow.elevation1.x,
                y: isPressed ? QShadow.elevation1.y * 0.5 : QShadow.elevation1.y
            )
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - QListRow（Q版列表行组件）
/// Q版列表行组件
/// 用于设置页、账号列表等场景的轻量级列表项
struct QListRow<Content: View>: View {
    let icon: String?
    let title: String
    let subtitle: String?
    let trailing: Content?
    let action: (() -> Void)?
    
    init(
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailing: () -> Content,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
        self.action = action
    }
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: QSpace.m) {
                // 左侧图标
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                        .foregroundColor(QColor.brand.accent)
                        .frame(width: 32)
                }
                
                // 中间标题和副标题
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(QFont.body)
                        .foregroundColor(QColor.text.onDarkPrimary)
                    
                    if let subtitleText = subtitle {
                        Text(subtitleText)
                            .font(QFont.caption)
                            .foregroundColor(QColor.text.onDarkSecondary)
                    }
                }
                
                Spacer()
                
                // 右侧内容
                if let trailingContent = trailing {
                    trailingContent
                }
            }
            .padding(QSpace.m)
            .background(
                RoundedRectangle(cornerRadius: QRadius.card)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: QRadius.card)
                            .stroke(Color.white.opacity(0.2), lineWidth: QStroke.thin)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - QListRowToggle（Q版列表行切换组件）
/// Q版列表行切换组件
/// 用于设置页的开关项
struct QListRowToggle: View {
    let icon: String?
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    init(
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: QSpace.m) {
            // 左侧图标
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(QColor.brand.accent)
                    .frame(width: 32)
            }
            
            // 中间标题和副标题
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(QFont.body)
                    .foregroundColor(QColor.text.onDarkPrimary)
                
                if let subtitleText = subtitle {
                    Text(subtitleText)
                        .font(QFont.caption)
                        .foregroundColor(QColor.text.onDarkSecondary)
                }
            }
            
            Spacer()
            
            // 右侧切换开关
            Toggle("", isOn: $isOn)
                .tint(QColor.brand.accent)
        }
        .padding(QSpace.m)
        .background(
            RoundedRectangle(cornerRadius: QRadius.card)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: QRadius.card)
                        .stroke(Color.white.opacity(0.2), lineWidth: QStroke.thin)
                )
        )
    }
}

// MARK: - View Extension for QStyle Modifiers
extension View {
    /// 应用 Q 版卡片样式
    func qCardStyle(radius: CGFloat = QRadius.card) -> some View {
        self.modifier(QCardStyle(radius: radius))
    }
    
    /// 应用 Q 版弹窗样式
    func qPopupStyle() -> some View {
        self.modifier(QPopupStyle())
    }
}

// MARK: - QFloatingDecoration（装饰漂浮动画）
/// Q版装饰漂浮动画组件
/// 用于星星、星球、数学符号等装饰元素的随机漂浮效果
/// 轻量实现，不影响布局，避免性能灾难
struct QFloatingDecoration: View {
    /// 装饰类型
    enum DecorationType {
        case star
        case planet
        case mathSymbol
    }
    
    let decorationType: DecorationType
    let size: CGFloat
    let xOffset: CGFloat
    let yOffset: CGFloat
    let duration: Double
    let delay: Double
    
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    init(
        decorationType: DecorationType,
        size: CGFloat = 40,
        xOffset: CGFloat = 0,
        yOffset: CGFloat = 0,
        duration: Double = 4.0,
        delay: Double = 0
    ) {
        self.decorationType = decorationType
        self.size = size
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.duration = duration
        self.delay = delay
    }
    
    var body: some View {
        // 根据装饰类型获取对应的图片
        switch decorationType {
        case .star:
            Image(QAsset.decoration.star)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .offset(x: xOffset, y: yOffset + offsetY)
                .opacity(opacity)
                .scaleEffect(scale)
                .onAppear {
                    // 淡入动画
                    withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                        opacity = 0.6 // 半透明，不干扰内容
                        scale = 1.0
                    }
                    
                    // 漂浮动画（上下缓慢移动）
                    withAnimation(
                        .easeInOut(duration: duration)
                            .repeatForever(autoreverses: true)
                            .delay(delay)
                    ) {
                        offsetY = -20 // 向上漂浮 20pt
                    }
                }
        case .planet:
            Image(QAsset.decoration.planet)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .offset(x: xOffset, y: yOffset + offsetY)
                .opacity(opacity)
                .scaleEffect(scale)
                .onAppear {
                    // 淡入动画
                    withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                        opacity = 0.6 // 半透明，不干扰内容
                        scale = 1.0
                    }
                    
                    // 漂浮动画（上下缓慢移动）
                    withAnimation(
                        .easeInOut(duration: duration)
                            .repeatForever(autoreverses: true)
                            .delay(delay)
                    ) {
                        offsetY = -20 // 向上漂浮 20pt
                    }
                }
        case .mathSymbol:
            Image(QAsset.decoration.mathSymbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .offset(x: xOffset, y: yOffset + offsetY)
                .opacity(opacity)
                .scaleEffect(scale)
                .onAppear {
                    // 淡入动画
                    withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                        opacity = 0.6 // 半透明，不干扰内容
                        scale = 1.0
                    }
                    
                    // 漂浮动画（上下缓慢移动）
                    withAnimation(
                        .easeInOut(duration: duration)
                            .repeatForever(autoreverses: true)
                            .delay(delay)
                    ) {
                        offsetY = -20 // 向上漂浮 20pt
                    }
                }
        }
    }
}

// MARK: - QFloatingDecorationView（装饰漂浮容器）
/// Q版装饰漂浮容器
/// 提供多个装饰元素的随机漂浮效果
/// 轻量实现，限制数量避免性能问题
struct QFloatingDecorationView: View {
    let decorationCount: Int
    
    init(decorationCount: Int = 5) {
        // 限制装饰数量，避免性能灾难
        self.decorationCount = min(max(decorationCount, 1), 8)
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<decorationCount, id: \.self) { index in
                QFloatingDecoration(
                    decorationType: randomDecorationType(index: index),
                    size: randomSize(index: index),
                    xOffset: randomXOffset(index: index),
                    yOffset: randomYOffset(index: index),
                    duration: randomDuration(index: index),
                    delay: Double(index) * 0.3
                )
            }
        }
    }
    
    /// 随机装饰类型
    private func randomDecorationType(index: Int) -> QFloatingDecoration.DecorationType {
        let types: [QFloatingDecoration.DecorationType] = [.star, .planet, .mathSymbol]
        return types[index % types.count]
    }
    
    /// 随机大小（30-60pt）
    private func randomSize(index: Int) -> CGFloat {
        let baseSize: CGFloat = 30
        let variation = CGFloat(index % 4) * 10
        return baseSize + variation
    }
    
    /// 随机 X 偏移（-150 到 150）
    private func randomXOffset(index: Int) -> CGFloat {
        let offsets: [CGFloat] = [-150, -100, -50, 0, 50, 100, 150]
        return offsets[index % offsets.count]
    }
    
    /// 随机 Y 偏移（-100 到 100）
    private func randomYOffset(index: Int) -> CGFloat {
        let offsets: [CGFloat] = [-100, -50, 0, 50, 100]
        return offsets[index % offsets.count]
    }
    
    /// 随机动画时长（3-6秒）
    private func randomDuration(index: Int) -> Double {
        let durations: [Double] = [3.0, 4.0, 5.0, 6.0]
        return durations[index % durations.count]
    }
}
