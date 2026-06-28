import SwiftUI

// MARK: - Tag 风格

enum TagStyle {
    case success   // 绿色 — 成交、已确认
    case warning   // 橙色 — 跟进中、待处理
    case error     // 红色 — 流失、过期
    case info      // 蓝色 — 普通信息
    case neutral   // 灰色 — 默认状态
    case ai        // AI 渐变 — AI 分析结果
    case primary   // 主色 — 品牌标签
    case custom(fg: Color, bg: Color)
}

// MARK: - Tag 尺寸

enum TagSize {
    case small   // 12pt 字体，紧凑内边距
    case medium  // 13pt 字体，标准内边距（默认）
}

// MARK: - Tag 组件

/// 通用标签组件 — 支持多种语义色、AI 渐变、自定义颜色
struct TagView: View {

    let text:  String
    var style: TagStyle = .neutral
    var size:  TagSize  = .medium
    var icon:  String?  = nil
    /// 是否显示左侧圆点（不显示图标时有效）
    var showDot: Bool = false

    var body: some View {
        HStack(spacing: dotSpacing) {
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: iconSize, weight: .medium))
            } else if showDot {
                Circle()
                    .fill(dotColor)
                    .frame(width: dotSize, height: dotSize)
            }
            Text(text)
                .font(size == .small ? AppFont.caption2 : AppFont.captionMedium)
                .lineLimit(1)
        }
        .padding(.horizontal, hPadding)
        .padding(.vertical, vPadding)
        .foregroundStyle(foregroundContent)
        .background(backgroundContent)
        .clipShape(Capsule())
    }

    // MARK: - 样式计算

    private var hPadding: CGFloat { size == .small ? 6 : AppSpacing.sm }
    private var vPadding: CGFloat { size == .small ? 2 : 4 }
    private var iconSize:  CGFloat { size == .small ? 10 : 12 }
    private var dotSize:   CGFloat { size == .small ? 5  : 6  }
    private var dotSpacing: CGFloat { size == .small ? 3 : 4  }

    private var dotColor: Color {
        switch style {
        case .success:  return AppColor.success
        case .warning:  return AppColor.warning
        case .error:    return AppColor.error
        case .info:     return AppColor.info
        case .primary:  return AppColor.primary
        case .neutral:  return AppColor.textLight
        case .ai:       return AppColor.aiPurple
        case .custom(let fg, _): return fg
        }
    }

    @ViewBuilder
    private var foregroundContent: some ShapeStyle {
        switch style {
        case .success:  AppColor.success
        case .warning:  AppColor.warning
        case .error:    AppColor.error
        case .info:     AppColor.info
        case .primary:  AppColor.primary
        case .neutral:  AppColor.textSecondary
        case .ai:       AnyShapeStyle(AppColor.aiGradient)
        case .custom(let fg, _): fg
        }
    }

    @ViewBuilder
    private var backgroundContent: some ShapeStyle {
        switch style {
        case .success:  AppColor.successBg
        case .warning:  AppColor.warningBg
        case .error:    AppColor.errorBg
        case .info:     AppColor.infoBg
        case .primary:  AppColor.primaryLight
        case .neutral:  AppColor.surface
        case .ai:       AnyShapeStyle(AppColor.aiGradient.opacity(0.12))
        case .custom(_, let bg): bg
        }
    }
}

// MARK: - Preview

#Preview("标签组件") {
    VStack(spacing: AppSpacing.md) {
        // 语义标签
        HStack(spacing: AppSpacing.sm) {
            TagView(text: "已成交", style: .success, showDot: true)
            TagView(text: "跟进中", style: .warning, showDot: true)
            TagView(text: "已流失", style: .error, showDot: true)
            TagView(text: "新客户", style: .info)
        }
        // AI 标签
        HStack(spacing: AppSpacing.sm) {
            TagView(text: "AI 高匹配", style: .ai, icon: "sparkles")
            TagView(text: "AI 画像", style: .ai, icon: "brain")
            TagView(text: "主推", style: .primary, icon: "star.fill")
        }
        // 图标标签
        HStack(spacing: AppSpacing.sm) {
            TagView(text: "学区房", style: .info, icon: "graduationcap")
            TagView(text: "近地铁", style: .success, icon: "tram.fill")
            TagView(text: "精装修", style: .neutral, icon: "paintbrush")
        }
        // 小号标签
        HStack(spacing: AppSpacing.xs) {
            TagView(text: "三房", style: .neutral, size: .small)
            TagView(text: "120㎡", style: .neutral, size: .small)
            TagView(text: "280万", style: .primary, size: .small)
        }
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
