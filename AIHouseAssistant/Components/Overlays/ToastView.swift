import SwiftUI

// MARK: - Toast 类型

enum ToastType {
    case success, warning, error, info

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error:   return "xmark.circle.fill"
        case .info:    return "info.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .success: return AppColor.success
        case .warning: return AppColor.warning
        case .error:   return AppColor.error
        case .info:    return AppColor.info
        }
    }
}

// MARK: - Toast 数据

struct ToastItem: Identifiable, Equatable {
    let id       = UUID()
    let message: String
    let type:    ToastType
    let duration: Double

    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool { lhs.id == rhs.id }
}

// MARK: - Toast 管理器

@MainActor
@Observable
final class ToastManager {

    static let shared = ToastManager()

    var current: ToastItem? = nil

    private init() {}

    func show(_ message: String, type: ToastType = .info, duration: Double = 2.8) {
        withAnimation(AppAnimation.appear) {
            current = ToastItem(message: message, type: type, duration: duration)
        }
        Task {
            try? await Task.sleep(for: .seconds(duration))
            withAnimation(AppAnimation.dismiss) {
                if current?.message == message { current = nil }
            }
        }
    }

    func success(_ message: String) { show(message, type: .success) }
    func warning(_ message: String) { show(message, type: .warning) }
    func error(_ message: String)   { show(message, type: .error, duration: 3.5) }
    func info(_ message: String)    { show(message, type: .info) }

    func dismiss() {
        withAnimation(AppAnimation.dismiss) { current = nil }
    }
}

// MARK: - Toast 视图

private struct ToastBubble: View {

    let item: ToastItem

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: item.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(item.type.color)

            Text(item.message)
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            Button {
                ToastManager.shared.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColor.textLight)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.base)
        .padding(.vertical, AppSpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .appShadow(AppShadow.popup)
        .padding(.horizontal, AppSpacing.base)
    }
}

// MARK: - Toast ViewModifier

struct ToastViewModifier: ViewModifier {

    @State private var manager = ToastManager.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let item = manager.current {
                    ToastBubble(item: item)
                        .padding(.top, AppSpacing.sm)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(999)
                }
            }
            .animation(AppAnimation.appear, value: manager.current)
    }
}

extension View {
    /// 为页面添加 Toast 显示能力（在根视图上调用一次即可）
    func toastOverlay() -> some View {
        modifier(ToastViewModifier())
    }
}

// MARK: - Preview

#Preview("Toast 提示") {
    VStack(spacing: AppSpacing.md) {
        AppButton.primary("成功提示") { ToastManager.shared.success("客户添加成功！") }
        AppButton(title: "警告提示", variant: .outline, action: { ToastManager.shared.warning("请先填写客户姓名") })
        AppButton.danger("错误提示") { ToastManager.shared.error("网络连接失败，请重试") }
        AppButton(title: "普通提示", variant: .secondary, action: { ToastManager.shared.info("AI 分析已完成，请查看结果") })
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
    .toastOverlay()
}
