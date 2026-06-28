import SwiftUI

/// 颜色系统 — 全局唯一颜色来源，支持深色模式自适应
/// 所有页面必须从此处取色，禁止直接写 Color.blue 等固定颜色
enum AppColor {

    // MARK: - 品牌色

    /// 主色（蓝）
    static let primary      = Color.adaptive(light: "#007AFF", dark: "#0A84FF")
    /// 主色浅背景（用于 Tag / Badge 背景）
    static let primaryLight = Color.adaptive(light: "#EBF4FF", dark: "#1C3048")
    /// 辅色（紫）
    static let secondary    = Color.adaptive(light: "#5856D6", dark: "#5E5CE6")

    // MARK: - 背景

    /// 页面背景
    static let background    = Color.adaptive(light: "#FFFFFF", dark: "#000000")
    /// 次要背景（分组列表底色）
    static let backgroundAlt = Color.adaptive(light: "#F2F2F7", dark: "#1C1C1E")
    /// 内容层背景
    static let surface       = Color.adaptive(light: "#F2F2F7", dark: "#1C1C1E")
    /// 卡片背景
    static let card          = Color.adaptive(light: "#FFFFFF", dark: "#2C2C2E")

    // MARK: - 描边 & 分割线

    /// 输入框、卡片描边
    static let border   = Color.adaptive(light: "#C6C6C8", dark: "#3A3A3C")
    /// 列表分割线
    static let divider  = Color.adaptive(light: "#E5E5EA", dark: "#2C2C2E")

    // MARK: - 语义色

    static let success    = Color(hex: "#34C759")
    static let successBg  = Color.adaptive(light: "#E8F9EE", dark: "#0D2816")
    static let warning    = Color(hex: "#FF9500")
    static let warningBg  = Color.adaptive(light: "#FFF3E0", dark: "#2D1A00")
    static let error      = Color(hex: "#FF3B30")
    static let errorBg    = Color.adaptive(light: "#FFEEED", dark: "#2D0A08")
    static let info       = Color(hex: "#5AC8FA")
    static let infoBg     = Color.adaptive(light: "#E8F6FF", dark: "#062333")

    // MARK: - 文字

    /// 主要文字
    static let textPrimary   = Color.adaptive(light: "#1C1C1E", dark: "#FFFFFF")
    /// 次要文字
    static let textSecondary = Color.adaptive(light: "#6C6C70", dark: "#8E8E93")
    /// 辅助文字（更浅）
    static let textLight     = Color.adaptive(light: "#8E8E93", dark: "#636366")
    /// 占位文字
    static let placeholder   = Color.adaptive(light: "#C7C7CC", dark: "#48484A")

    // MARK: - AI 专属色

    static let aiPurple = Color(hex: "#7B61FF")
    static let aiBlue   = Color(hex: "#00C4FF")
    static let aiGold   = Color(hex: "#FFB800")

    /// AI 渐变
    static var aiGradient: LinearGradient {
        LinearGradient(
            colors: [aiPurple, aiBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - 阴影基色

    static let shadowColor = Color.black.opacity(0.08)
}

// MARK: - Color 自适应扩展

extension Color {
    /// 创建深色模式自适应颜色
    static func adaptive(light lightHex: String, dark darkHex: String) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: darkHex))
                : UIColor(Color(hex: lightHex))
        })
    }
}
