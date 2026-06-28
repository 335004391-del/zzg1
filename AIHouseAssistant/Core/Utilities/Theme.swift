import SwiftUI

/// 全局主题系统 — 颜色、字体、圆角、间距、阴影统一管理
/// 禁止在业务代码中硬编码任何样式值
enum Theme {

    // MARK: - 颜色

    enum Color {
        /// 主品牌色
        static let primary       = SwiftUI.Color("ColorPrimary")
        /// 辅助色
        static let secondary     = SwiftUI.Color("ColorSecondary")
        /// 强调色（按钮、高亮）
        static let accent        = SwiftUI.Color("ColorAccent")

        /// 背景色（页面级）
        static let background    = SwiftUI.Color("ColorBackground")
        /// 卡片背景
        static let surface       = SwiftUI.Color("ColorSurface")
        /// 分割线 / 描边
        static let separator     = SwiftUI.Color("ColorSeparator")

        /// 主文字
        static let textPrimary   = SwiftUI.Color("ColorTextPrimary")
        /// 次要文字
        static let textSecondary = SwiftUI.Color("ColorTextSecondary")
        /// 占位文字
        static let textTertiary  = SwiftUI.Color("ColorTextTertiary")

        /// 成功
        static let success        = SwiftUI.Color("ColorSuccess")
        /// 警告
        static let warning        = SwiftUI.Color("ColorWarning")
        /// 错误
        static let error          = SwiftUI.Color("ColorError")
        /// 信息
        static let info           = SwiftUI.Color("ColorInfo")
    }

    // MARK: - 字体

    enum Font {
        /// 大标题  34pt
        static let largeTitle  = SwiftUI.Font.largeTitle
        /// 标题 1  28pt
        static let title1      = SwiftUI.Font.title
        /// 标题 2  22pt
        static let title2      = SwiftUI.Font.title2
        /// 标题 3  20pt
        static let title3      = SwiftUI.Font.title3
        /// 正文      17pt
        static let body        = SwiftUI.Font.body
        /// 标注      15pt
        static let callout     = SwiftUI.Font.callout
        /// 副标题   16pt
        static let subheadline = SwiftUI.Font.subheadline
        /// 脚注      13pt
        static let footnote    = SwiftUI.Font.footnote
        /// 说明文字 12pt
        static let caption1    = SwiftUI.Font.caption
        /// 更小说明 11pt
        static let caption2    = SwiftUI.Font.caption2
    }

    // MARK: - 圆角

    enum Radius {
        static let small:  CGFloat = 6
        static let medium: CGFloat = 12
        static let large:  CGFloat = 16
        static let xLarge: CGFloat = 24
        static let full:   CGFloat = 9999
    }

    // MARK: - 间距

    enum Spacing {
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let base: CGFloat = 16
        static let lg:  CGFloat = 20
        static let xl:  CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - 阴影

    enum Shadow {
        /// 轻微阴影（卡片）
        static let small  = ShadowStyle(color: .black.opacity(0.06), radius: 4,  x: 0, y: 2)
        /// 标准阴影（浮层）
        static let medium = ShadowStyle(color: .black.opacity(0.10), radius: 12, x: 0, y: 4)
        /// 深阴影（模态）
        static let large  = ShadowStyle(color: .black.opacity(0.16), radius: 24, x: 0, y: 8)
    }

    // MARK: - 图标尺寸

    enum IconSize {
        static let small:  CGFloat = 16
        static let medium: CGFloat = 20
        static let large:  CGFloat = 24
        static let xLarge: CGFloat = 32
    }
}

// MARK: - 阴影样式数据类型

struct ShadowStyle {
    let color:  SwiftUI.Color
    let radius: CGFloat
    let x:      CGFloat
    let y:      CGFloat
}

// MARK: - View 阴影扩展

extension View {
    /// 统一应用主题阴影
    func themeShadow(_ style: ShadowStyle) -> some View {
        self.shadow(
            color:  style.color,
            radius: style.radius,
            x:      style.x,
            y:      style.y
        )
    }
}
