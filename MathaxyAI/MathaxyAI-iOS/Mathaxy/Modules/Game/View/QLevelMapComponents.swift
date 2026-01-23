//
//  QLevelMapComponents.swift
//  Mathaxy
//
//  关卡选择页（新版）地图组件：顶部导航 + 蛇形路径 + 2.5D 关卡节点
//
//  说明：
//  - 为了保证“先能编译跑起来”，本文件对图片资源采用“有则用、无则降级为矢量绘制”的策略。
//  - 当你把 2.5D 关卡图标与圆形返回按钮资源加入 Assets.xcassets 后，会自动切换为图片渲染。
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 新版资源名（先用本地常量，后续可迁移到 QDesignTokens/QAsset）
private enum QNewAsset {
    // 2.5D 关卡节点三态（建议你后续在 Assets.xcassets 中创建同名 imageset）
    static let levelNodeLocked = "level_node_locked_2_5d_qstyle"
    static let levelNodeAvailable = "level_node_available_2_5d_qstyle"
    static let levelNodeCompleted = "level_node_completed_2_5d_qstyle"

    // 顶部圆形返回按钮（建议 imageset 名）
    static let navBackCircle = "nav_back_circle_qstyle"
}

// MARK: - 工具：判断资源是否存在（避免缺资源导致 UI 不可用）
private func qAssetExists(_ name: String) -> Bool {
    #if canImport(UIKit)
    return UIImage(named: name) != nil
    #else
    return false
    #endif
}

// MARK: - 顶部导航（返回 + 标题）
struct QTopNavBar: View {

    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: QSpace.m) {
            QBackCircleButton(action: onBack)
                .accessibilityLabel(Text(LocalizedKeys.back.localized))

            Spacer(minLength: 0)

            Text(title)
                .font(QFont.titlePage)
                .foregroundColor(QColor.text.onDarkPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            // 右侧占位，保证标题视觉居中
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, QSpace.pagePadding)
        .padding(.top, QSpace.m)
        .padding(.bottom, QSpace.s)
    }
}

// MARK: - Q版圆形返回按钮（优先用图片，否则矢量绘制 2.5D）
struct QBackCircleButton: View {

    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                if qAssetExists(QNewAsset.navBackCircle) {
                    Image(QNewAsset.navBackCircle)
                        .resizable()
                        .scaledToFit()
                } else {
                    // 降级绘制：2.5D 小圆钮（左上高光，右下阴影）
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0x3A3A57), Color(hex: 0x2D2D44)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(QColor.brand.accent.opacity(0.9), lineWidth: 1.5)
                        )
                        .overlay(
                            // 左上高光弧
                            Circle()
                                .trim(from: 0.05, to: 0.32)
                                .stroke(Color.white.opacity(0.22), style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                                .rotationEffect(.degrees(-40))
                                .padding(4)
                        )

                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.92))
                        .offset(x: -1)
                }
            }
            .frame(width: 44, height: 44)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: isPressed ? 2 : 4)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - 蛇形路径布局参数
struct QLevelMapLayout {
    /// 每行节点数（建议 4 或 5，根据屏幕宽度可动态选择）
    let columns: Int

    /// 节点视觉尺寸（pt）
    let nodeSize: CGFloat

    /// 节点命中区域（pt，>= nodeSize）
    let hitSize: CGFloat

    /// 横向边距
    let horizontalPadding: CGFloat

    /// 顶部内容边距（留给标题与装饰）
    let topPadding: CGFloat

    /// 行间距
    let dy: CGFloat

    /// 列间距（由宽度计算，也可给默认）
    let dx: CGFloat

    /// 曲线鼓起程度
    let curveBend: CGFloat

    /// 轻微抖动范围（使路径不死板）
    let jitterX: CGFloat
    let jitterY: CGFloat

    static func `default`(for width: CGFloat) -> QLevelMapLayout {
        // 小屏用 4 列，大屏可 5 列
        let columns = width < 380 ? 4 : 5
        let nodeSize: CGFloat = 92
        let hitSize: CGFloat = 104
        let horizontalPadding: CGFloat = QSpace.pagePadding
        let topPadding: CGFloat = 12
        let dy: CGFloat = 140
        let usableWidth = max(0, width - horizontalPadding * 2)
        let dx = columns <= 1 ? usableWidth : (usableWidth / CGFloat(columns - 1))

        return QLevelMapLayout(
            columns: columns,
            nodeSize: nodeSize,
            hitSize: hitSize,
            horizontalPadding: horizontalPadding,
            topPadding: topPadding,
            dy: dy,
            dx: dx,
            curveBend: min(50, dx * 0.35),
            jitterX: 10,
            jitterY: 6
        )
    }
}

// MARK: - 关卡节点状态
enum QLevelNodeState {
    case locked
    case available
    case current
    case completed

    var isEnabled: Bool {
        switch self {
        case .locked:
            return false
        default:
            return true
        }
    }
}

// MARK: - 关卡节点展示数据
struct QLevelNodeViewData: Identifiable {
    let id: Int
    let level: Int
    let state: QLevelNodeState

    init(level: Int, state: QLevelNodeState) {
        self.id = level
        self.level = level
        self.state = state
    }
}

// MARK: - 关卡地图（蛇形/之字形）
struct QLevelPathMap: View {

    let nodes: [QLevelNodeViewData]
    let onTapLevel: (Int) -> Void

    var body: some View {
        GeometryReader { proxy in
            let layout = QLevelMapLayout.default(for: proxy.size.width)
            ScrollView(.vertical, showsIndicators: false) {
                ZStack(alignment: .topLeading) {
                    // 连接线层
                    QLevelConnectorLayer(nodes: nodes, layout: layout)
                        .padding(.top, layout.topPadding)

                    // 节点层
                    ForEach(nodes) { node in
                        let point = qPoint(for: node.level, width: proxy.size.width, layout: layout)

                        QLevelNode2_5D(level: node.level, state: node.state) {
                            onTapLevel(node.level)
                        }
                        .frame(width: layout.hitSize, height: layout.hitSize)
                        .position(x: point.x, y: point.y)
                        // 保证锚点为节点视觉中心，连线与节点中心精确对接
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: qContentHeight(total: nodes.count, layout: layout)
                )
                .padding(.bottom, 120) // 预留底部信息区高度
            }
        }
    }

    private func qContentHeight(total: Int, layout: QLevelMapLayout) -> CGFloat {
        let rows = Int(ceil(Double(total) / Double(layout.columns)))
        return layout.topPadding + CGFloat(max(1, rows)) * layout.dy + 60
    }

    /// 将关卡序号映射到左-中-右-中-左...蛇形坐标，保证第一关左上，第二关中，第三关右，第四关中，第五关左...
    private func qPoint(for level: Int, width: CGFloat, layout: QLevelMapLayout) -> CGPoint {
        // level 从 1 开始
        let index = max(0, level - 1)
        // 水平方向：左-中-右-中-左... 循环
        let positions: [CGFloat] = [0.18, 0.5, 0.82, 0.5] // 左、中、右、中
        let posIndex = index % 4
        let xPos = positions[posIndex]
        let usableWidth = width - layout.horizontalPadding * 2
        let centerX = layout.horizontalPadding + usableWidth * xPos
        // 垂直方向：每两关高度差不超过一个关卡高度
        // 纵向：每一关都比上一关略低，形成阶梯感
        let y = layout.topPadding + CGFloat(index) * layout.hitSize * 0.85 + layout.hitSize / 2
        // 轻微抖动，避免死板
        let jx = CGFloat(((level * 37) % 21) - 10) / 10.0 * layout.jitterX
        let jy = CGFloat(((level * 53) % 13) - 6) / 6.0 * layout.jitterY
        return CGPoint(x: centerX + jx, y: y + jy)
    }
}

// MARK: - 连接线层（软管发光）
struct QLevelConnectorLayer: View {

    let nodes: [QLevelNodeViewData]
    let layout: QLevelMapLayout

    var body: some View {
        Canvas { context, size in
            guard nodes.count >= 2 else { return }

            // 预计算点位
            var points: [CGPoint] = []
            points.reserveCapacity(nodes.count)

            for node in nodes {
                let p = qPoint(for: node.level, width: size.width, layout: layout)
                points.append(p)
                // Debug: 输出每个点坐标，便于排查连线缺失问题
                // print("Level \(node.level): (\(p.x), \(p.y))")
            }

            // 逐段绘制（i -> i+1）
            for i in 0..<(points.count - 1) {
                let p0 = points[i]
                let p1 = points[i + 1]

                // 当前段状态：若下一关已完成/可达，则高亮，否则灰
                let segmentState = qSegmentState(from: nodes[i], to: nodes[i + 1])

                var path = Path()
                path.move(to: p0)

                let mid = CGPoint(x: (p0.x + p1.x) / 2, y: (p0.y + p1.y) / 2)
                // 连线弧度优化：每段用起点和终点的x差决定弯曲方向和幅度
                let dx = p1.x - p0.x
                let dy = p1.y - p0.y
                let curveStrength: CGFloat = 0.35 // 弧度强度
                let cp = CGPoint(
                    x: (p0.x + p1.x) / 2 + curveStrength * dy * (dx > 0 ? 1 : -1),
                    y: (p0.y + p1.y) / 2 - curveStrength * abs(dx)
                )
                path.addQuadCurve(to: p1, control: cp)

                // 外发光
                context.stroke(
                    path,
                    with: .color(segmentState.glowColor),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round, lineJoin: .round)
                )

                // 内核
                context.stroke(
                    path,
                    with: .color(segmentState.strokeColor),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round)
                )
            }
        }
        .allowsHitTesting(false)
    }

    private struct SegmentVisual {
        let strokeColor: Color
        let glowColor: Color
    }

    private func qSegmentState(from: QLevelNodeViewData, to: QLevelNodeViewData) -> SegmentVisual {
        // 连线颜色与from节点（即上一关）保持一致，当前关卡高亮
        switch from.state {
        case .current:
            return SegmentVisual(
                strokeColor: QColor.brand.accent.opacity(0.95),
                glowColor: QColor.brand.accent.opacity(0.25)
            )
        case .completed:
            return SegmentVisual(
                strokeColor: QColor.brand.accent.opacity(0.95),
                glowColor: QColor.brand.accent.opacity(0.25)
            )
        case .available:
            return SegmentVisual(
                strokeColor: QColor.brand.accent.opacity(0.75),
                glowColor: QColor.brand.accent.opacity(0.18)
            )
        case .locked:
            return SegmentVisual(
                strokeColor: Color.white.opacity(0.22),
                glowColor: Color.white.opacity(0.06)
            )
        }
    }

    private func qPoint(for level: Int, width: CGFloat, layout: QLevelMapLayout) -> CGPoint {
        let index = max(0, level - 1)
        let c0 = index % layout.columns
        let r = index / layout.columns
        let c = r.isMultiple(of: 2) ? c0 : (layout.columns - 1 - c0)

        let baseX = layout.horizontalPadding + CGFloat(c) * layout.dx
        let baseY = layout.topPadding + CGFloat(r) * layout.dy + layout.hitSize / 2

        let jx = CGFloat(((level * 37) % 21) - 10) / 10.0 * layout.jitterX
        let jy = CGFloat(((level * 53) % 13) - 6) / 6.0 * layout.jitterY

        return CGPoint(x: baseX + jx, y: baseY + jy)
    }
}

// MARK: - 2.5D 关卡节点（优先用图片，否则矢量绘制）
struct QLevelNode2_5D: View {

    let level: Int
    let state: QLevelNodeState
    let onTap: () -> Void

    @State private var isPressed = false
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // 若存在 2.5D 图片资源，优先使用
                if let imgName = qImageName(for: state), qAssetExists(imgName) {
                    Image(imgName)
                        .resizable()
                        .scaledToFit()
                } else {
                    // 降级绘制：顶面+侧面+投影+高光
                    qFallback2_5DNode
                }

                // 数字层
                Text("\(level)")
                    .font(Font.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(qNumberColor)
                    .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 2)
                    .opacity(state == .locked ? 0.35 : 1.0)

                // 状态叠加
                qStateOverlay
            }
            .frame(width: 104, height: 104)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .offset(y: state == .current ? floatOffset : 0)
            .animation(.easeInOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(!state.isEnabled)
        .onLongPressGesture(minimumDuration: 0, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .onAppear {
            guard state == .current else { return }
            // 当前关卡轻微浮动（可后续加入 Reduce Motion 降级逻辑）
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                floatOffset = -3
            }
        }
    }

    private func qImageName(for state: QLevelNodeState) -> String? {
        switch state {
        case .locked:
            return QNewAsset.levelNodeLocked
        case .available, .current:
            return QNewAsset.levelNodeAvailable
        case .completed:
            return QNewAsset.levelNodeCompleted
        }
    }

    private var qNumberColor: Color {
        switch state {
        case .current:
            return QColor.text.onLightPrimary
        default:
            return QColor.text.onDarkPrimary
        }
    }

    @ViewBuilder
    private var qStateOverlay: some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(QColor.state.success)
                .offset(x: 32, y: -32)

        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(QColor.text.onDarkSecondary)

        case .current:
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 12, height: 12)
                .shadow(color: QColor.brand.accent.opacity(0.35), radius: 10, x: 0, y: 0)
                .offset(x: 32, y: -32)

        case .available:
            EmptyView()
        }
    }

    private var qFallback2_5DNode: some View {
        ZStack {
            // Q版2.5D节点：更立体更萌
            // 地面投影
            Ellipse()
                .fill(Color.black.opacity(state == .current ? 0.32 : 0.22))
                .frame(width: 92, height: 24)
                .blur(radius: 14)
                .offset(y: 20)

            // 侧面（右下偏移，带渐变和Q版高光）
            Circle()
                .fill(
                    LinearGradient(
                        colors: [qSideColor, qSideColor.opacity(0.7), Color.white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 96, height: 96)
                .offset(x: 7, y: 10)
                .blur(radius: 0.5)
                .overlay(
                    // 右下高光
                    Circle()
                        .trim(from: 0.6, to: 0.85)
                        .stroke(Color.white.opacity(0.10), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(30))
                        .padding(8)
                )

            // 顶面（更Q更立体，带Q版高光和Q色描边）
            Circle()
                .fill(qTopGradient)
                .frame(width: 92, height: 92)
                .overlay(
                    Circle()
                        .stroke(qRimColor, lineWidth: 3)
                )
                .overlay(
                    // 左上高光弧（更宽更亮）
                    Circle()
                        .trim(from: 0.04, to: 0.38)
                        .stroke(Color.white.opacity(qHighlightOpacity + 0.08), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-38))
                        .padding(5)
                )
                .overlay(
                    // Q版小反光点
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 16, height: 10)
                        .offset(x: -18, y: -18)
                )
                .shadow(color: Color.black.opacity(state == .current ? 0.28 : 0.18), radius: state == .current ? 14 : 10, x: 0, y: state == .current ? 8 : 6)
        }
    }

    private var qTopGradient: LinearGradient {
        switch state {
        case .completed:
            return LinearGradient(
                colors: [Color(hex: 0x34E39A), Color(hex: 0x00C851), Color(hex: 0x00A744)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .current:
            return LinearGradient(
                colors: [Color(hex: 0xFFF2A6), Color(hex: 0xFFD700), Color(hex: 0xFFA500)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .available:
            return LinearGradient(
                colors: [Color(hex: 0xFFE9A6), Color(hex: 0xFFD700), Color(hex: 0xE3A500)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .locked:
            return LinearGradient(
                colors: [Color(hex: 0x3A3A57), Color(hex: 0x2D2D44), Color(hex: 0x1A1A2E)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var qSideColor: Color {
        switch state {
        case .completed:
            return Color(hex: 0x007A36)
        case .current, .available:
            return Color(hex: 0xC97A00)
        case .locked:
            return Color(hex: 0x161626)
        }
    }

    private var qRimColor: Color {
        switch state {
        case .locked:
            return Color.white.opacity(0.18)
        case .completed:
            return QColor.brand.accent
        case .current:
            return Color.white.opacity(0.35)
        case .available:
            return Color.white.opacity(0.25)
        }
    }

    private var qHighlightOpacity: Double {
        switch state {
        case .locked:
            return 0.14
        case .completed:
            return 0.22
        case .available:
            return 0.18
        case .current:
            return 0.28
        }
    }
}
