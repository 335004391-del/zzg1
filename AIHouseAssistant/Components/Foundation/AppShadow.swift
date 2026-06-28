import SwiftUI

/// 阴影系统 — 统一阴影层级定义
struct AppShadowStyle {
    let color:  Color
    let radius: CGFloat
    let x:      CGFloat
    let y:      CGFloat
}

enum AppShadow {
    /// 卡片阴影（轻微浮起）
    static let card     = AppShadowStyle(color: .black.opacity(0.06), radius: 8,  x: 0, y: 2)
    /// 弹出层阴影（下拉菜单、Popover）
    static let popup    = AppShadowStyle(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
    /// 浮动层阴影（底部栏、FAB）
    static let floating = AppShadowStyle(color: .black.opacity(0.18), radius: 32, x: 0, y: 12)
}

// MARK: - View 扩展

extension View {
    /// 应用统一阴影风格
    func appShadow(_ style: AppShadowStyle) -> some View {
        shadow(
            color:  style.color,
            radius: style.radius,
            x:      style.x,
            y:      style.y
        )
    }
}
