import SwiftUI

/// 动画系统 — 统一动画曲线与时长，保持 Apple 原生质感
enum AppAnimation {

    // MARK: - 弹簧动画

    /// 按钮点击（快速回弹）
    static let buttonPress  = Animation.spring(response: 0.25, dampingFraction: 0.7)
    /// 卡片展开 / 折叠
    static let cardToggle   = Animation.spring(response: 0.35, dampingFraction: 0.8)
    /// 弹窗出现
    static let modal        = Animation.spring(response: 0.4,  dampingFraction: 0.85)

    // MARK: - 缓动动画

    /// 极快（状态切换，不引人注意）
    static let instant  = Animation.easeInOut(duration: 0.10)
    /// 快速（Tab 切换、小元素）
    static let fast     = Animation.easeInOut(duration: 0.18)
    /// 标准（大多数 UI 状态变化）
    static let normal   = Animation.easeInOut(duration: 0.25)
    /// 缓慢（页面级过渡）
    static let slow     = Animation.easeInOut(duration: 0.38)

    // MARK: - 出现 / 消失

    /// 弹出层出现
    static let appear  = Animation.easeOut(duration: 0.28)
    /// 弹出层消失
    static let dismiss = Animation.easeIn(duration: 0.22)

    // MARK: - 过渡效果

    /// 标准卡片出现过渡
    static var cardTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal:   .opacity
        )
    }

    /// 底部弹出层过渡
    static var bottomSheetTransition: AnyTransition {
        .move(edge: .bottom)
    }

    /// 淡入淡出过渡
    static var fadeTransition: AnyTransition {
        .opacity
    }

    /// 缩放 + 淡入（弹窗）
    static var popupTransition: AnyTransition {
        .scale(scale: 0.92).combined(with: .opacity)
    }
}
