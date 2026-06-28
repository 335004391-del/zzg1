import SwiftUI

/// 字体系统 — 统一字体定义，所有字体均支持 Dynamic Type 自动缩放
/// 业务代码全部使用此处定义的字体，禁止硬编码字号
enum AppFont {

    // MARK: - 标题

    /// 超大标题（欢迎页、启动页）34pt
    static let titleLarge    = Font.largeTitle.weight(.bold)
    /// 页面主标题（导航栏）22pt
    static let title         = Font.title2.weight(.bold)
    /// 卡片标题、section 标题 20pt
    static let title3        = Font.title3.weight(.semibold)
    /// 列表 headline 17pt
    static let headline      = Font.headline

    // MARK: - 正文

    /// 正文（主要内容）17pt
    static let body          = Font.body
    /// 正文加粗
    static let bodyMedium    = Font.body.weight(.medium)
    /// 正文半粗（强调）
    static let bodySemibold  = Font.body.weight(.semibold)
    /// 小号正文（辅助描述）15pt
    static let bodySmall     = Font.subheadline

    // MARK: - 辅助

    /// 标注（输入框标签、表单说明）15pt
    static let callout       = Font.callout
    /// 脚注（统计数字旁标签）13pt
    static let label         = Font.footnote
    /// 脚注加粗
    static let labelMedium   = Font.footnote.weight(.medium)
    /// 说明文字（时间戳、次要 Meta）12pt
    static let caption       = Font.caption
    /// 说明文字加粗
    static let captionMedium = Font.caption.weight(.medium)
    /// 更小说明文字 11pt
    static let caption2      = Font.caption2

    // MARK: - 功能性

    /// 按钮文字（标准）
    static let button        = Font.body.weight(.semibold)
    /// 小按钮文字
    static let buttonSmall   = Font.subheadline.weight(.semibold)
    /// 数字大展示（统计卡片）
    static let display       = Font.system(size: 34, weight: .bold, design: .rounded)
    /// 数字中展示
    static let displayMedium = Font.system(size: 24, weight: .semibold, design: .rounded)
}
