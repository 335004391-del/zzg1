import CoreFoundation

/// 圆角系统 — 统一圆角定义
/// 所有 cornerRadius 必须从此处取值，禁止硬编码
enum AppRadius {
    /// 4pt — 小 Tag、角标
    static let xs:   CGFloat = 4
    /// 8pt — 输入框、小卡片
    static let sm:   CGFloat = 8
    /// 12pt — 标准卡片
    static let md:   CGFloat = 12
    /// 16pt — 大卡片、模态
    static let lg:   CGFloat = 16
    /// 20pt — 底部弹出层顶部圆角
    static let xl:   CGFloat = 20
    /// 28pt — 超大卡片、启动页元素
    static let xxl:  CGFloat = 28
    /// 无限大 — 胶囊形按钮、搜索框
    static let full: CGFloat = 999
}
