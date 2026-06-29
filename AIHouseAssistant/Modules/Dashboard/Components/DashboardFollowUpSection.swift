import SwiftUI

/// 待跟进客户 Section —— 标题 + 客户列表
struct DashboardFollowUpSection: View {

    /// 待跟进客户
    let followUps: [DashboardFollowUp]
    /// 点击某客户「查看详情」
    var onTapCustomer: (String) -> Void
    /// 点击「查看全部」
    var onViewAll: () -> Void

    var body: some View {
        SectionCard(
            title: "待跟进客户",
            subtitle: "共 \(followUps.count) 位",
            icon: "bell.badge",
            actionTitle: "查看全部",
            onAction: onViewAll
        ) {
            VStack(spacing: 0) {
                ForEach(Array(followUps.enumerated()), id: \.element.id) { index, item in
                    DashboardFollowUpRow(item: item) {
                        onTapCustomer(item.id)
                    }
                    if index < followUps.count - 1 {
                        Divider().foregroundStyle(AppColor.divider)
                    }
                }
            }
        }
    }
}

// MARK: - 单行客户

private struct DashboardFollowUpRow: View {

    let item: DashboardFollowUp
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {

                // 头像（首字占位）
                Text(item.avatarText)
                    .font(AppFont.bodySemibold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(AppColor.primary.gradient)
                    .clipShape(Circle())

                // 客户信息
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.sm) {
                        Text(item.name)
                            .font(AppFont.bodyMedium)
                            .foregroundStyle(AppColor.textPrimary)
                        TagView(text: item.area, style: .info, size: .small)
                    }
                    HStack(spacing: AppSpacing.sm) {
                        Label(item.budget, systemImage: "yensign.circle")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                        Text("·")
                            .foregroundStyle(AppColor.textLight)
                        Text(item.lastContact)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textLight)
                    }
                }

                Spacer()

                // 成交概率 + 箭头
                VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                    Text("\(item.dealProbability)%")
                        .font(AppFont.bodySemibold)
                        .foregroundStyle(probabilityColor)
                    HStack(spacing: 2) {
                        Text("详情")
                            .font(AppFont.caption2)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(AppColor.textLight)
                }
            }
            .padding(.vertical, AppSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// 概率配色：高=绿，中=橙，低=灰
    private var probabilityColor: Color {
        switch item.dealProbability {
        case 80...:   return AppColor.success
        case 60..<80: return AppColor.warning
        default:      return AppColor.textSecondary
        }
    }
}

// MARK: - Preview

#Preview("待跟进客户") {
    ScrollView {
        DashboardFollowUpSection(
            followUps: DashboardOverview.mock.followUps,
            onTapCustomer: { _ in },
            onViewAll: {}
        )
        .padding(AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
