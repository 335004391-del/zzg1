import SwiftUI

/// 空状态视图 — 列表无数据时显示
struct EmptyStateView: View {

    let icon:       String
    let title:      String
    let message:    String
    var actionTitle: String? = nil
    var onAction:   (() -> Void)? = nil
    var iconColor:  Color = AppColor.textLight

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            VStack(spacing: AppSpacing.lg) {
                // 图标
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.08))
                        .frame(width: 88, height: 88)
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(iconColor.opacity(0.5))
                }

                // 文字
                VStack(spacing: AppSpacing.sm) {
                    Text(title)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // 操作按钮
                if let actionTitle, let onAction {
                    AppButton(title: actionTitle, icon: "plus",
                              variant: .primary, action: onAction)
                }
            }
            .padding(.horizontal, AppSpacing.xxxl)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("空状态视图") {
    VStack {
        EmptyStateView(
            icon: "person.3",
            title: "暂无客户",
            message: "还没有添加任何客户\n点击下方按钮开始添加",
            actionTitle: "添加客户",
            iconColor: AppColor.primary,
            onAction: {}
        )
    }
    .background(AppColor.background)
}
