import SwiftUI

/// 首页通用 Section 标题行 —— 图标 + 标题 + 右侧操作
/// 用于「最新房源」「AI 推荐」「快捷功能」等非卡片包裹的分区
struct DashboardSectionHeader: View {

    let title: String
    var icon: String? = nil
    var actionTitle: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.primary)
            }
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            if let actionTitle, let onAction {
                Button(action: onAction) {
                    HStack(spacing: 2) {
                        Text(actionTitle)
                            .font(AppFont.captionMedium)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppColor.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.base)
    }
}

// MARK: - Preview

#Preview("Section 标题") {
    VStack(spacing: AppSpacing.lg) {
        DashboardSectionHeader(title: "最新房源", icon: "building.2",
                               actionTitle: "查看全部", onAction: {})
        DashboardSectionHeader(title: "快捷功能", icon: "square.grid.2x2")
    }
    .padding(.vertical, AppSpacing.base)
    .background(AppColor.background)
}
