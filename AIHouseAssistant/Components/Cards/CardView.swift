import SwiftUI

/// 基础卡片容器 — 所有业务卡片的基础组件
/// 统一背景、圆角、阴影
struct CardView<Content: View>: View {

    var padding: CGFloat = AppSpacing.base
    var radius:  CGFloat = AppRadius.lg
    var shadow:  AppShadowStyle = AppShadow.card
    var backgroundColor: Color = AppColor.card
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .appShadow(shadow)
    }
}

// MARK: - 可点击卡片

/// 带点击效果的卡片（列表行、可展开项）
struct TappableCardView<Content: View>: View {

    var padding: CGFloat = AppSpacing.base
    var radius:  CGFloat = AppRadius.lg
    let action:  () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            CardView(padding: padding, radius: radius) {
                content()
            }
        }
        .buttonStyle(AppPressCardStyle())
    }
}

private struct AppPressCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("基础卡片") {
    VStack(spacing: AppSpacing.lg) {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("基础卡片").font(AppFont.headline)
                Text("用于包裹任意内容").font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }

        TappableCardView(action: {}) {
            HStack {
                Text("可点击卡片").font(AppFont.bodyMedium)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColor.textLight)
            }
        }
    }
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
