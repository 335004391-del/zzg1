import SwiftUI

// MARK: - 通用 View 扩展

extension View {

    /// 隐藏/显示控件
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden { self.hidden() } else { self }
    }

    /// 标准卡片样式
    func cardStyle(
        radius: CGFloat = Theme.Radius.medium,
        padding: CGFloat = Theme.Spacing.base
    ) -> some View {
        self
            .padding(padding)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .themeShadow(Theme.Shadow.small)
    }
}
