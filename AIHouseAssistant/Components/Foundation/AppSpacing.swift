import CoreFoundation

/// 间距系统 — 统一间距定义，禁止页面中出现魔法数字
/// 所有 padding、spacing 必须从此处取值
enum AppSpacing {
    /// 4pt — 图标与文字间距、角标内边距
    static let xs:   CGFloat = 4
    /// 8pt — 紧凑间距、Tag 内边距
    static let sm:   CGFloat = 8
    /// 12pt — 卡片内元素间距
    static let md:   CGFloat = 12
    /// 16pt — 标准页面内边距
    static let base: CGFloat = 16
    /// 20pt — 卡片与卡片间距
    static let lg:   CGFloat = 20
    /// 24pt — section 间距
    static let xl:   CGFloat = 24
    /// 32pt — 大模块间距
    static let xxl:  CGFloat = 32
    /// 40pt — 页面顶部留白
    static let xxxl: CGFloat = 40
    /// 48pt — 超大留白（空状态、欢迎页）
    static let xxxxl: CGFloat = 48

    // MARK: - 语义化快捷别名

    /// 页面水平内边距
    static let pagePadding: CGFloat = base
    /// 卡片内边距
    static let cardPadding: CGFloat = base
    /// 列表行高度（不含内边距）
    static let rowHeight:   CGFloat = 52
    /// 底部安全区额外补偿
    static let bottomSafe:  CGFloat = 16
}
