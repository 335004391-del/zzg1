import SwiftUI

/// AI 推荐 Section —— 推荐客户 → 推荐房源 → 匹配度
struct DashboardRecommendationSection: View {

    /// 推荐列表
    let recommendations: [DashboardRecommendation]
    /// 点击「查看推荐理由」
    var onViewReason: (DashboardRecommendation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            DashboardSectionHeader(title: "AI 推荐", icon: "sparkles")

            VStack(spacing: AppSpacing.md) {
                ForEach(recommendations) { item in
                    DashboardRecommendationCard(item: item) {
                        onViewReason(item)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.base)
        }
    }
}

// MARK: - 单个推荐卡片

private struct DashboardRecommendationCard: View {

    let item: DashboardRecommendation
    let onViewReason: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {

                // 客户 → 房源 → 匹配度
                HStack(spacing: AppSpacing.md) {
                    flowNode(icon: "person.fill", label: "推荐客户", value: item.customerName)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColor.textLight)

                    flowNode(icon: "house.fill", label: "推荐房源", value: item.houseName)

                    Spacer()

                    // 匹配度
                    matchBadge
                }

                Divider().foregroundStyle(AppColor.divider)

                // 查看推荐理由
                Button(action: onViewReason) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 13, weight: .medium))
                        Text("查看推荐理由")
                            .font(AppFont.captionMedium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(AppColor.aiPurple)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 子视图

    private func flowNode(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Label(label, systemImage: icon)
                .font(AppFont.caption2)
                .foregroundStyle(AppColor.textLight)
            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
        }
    }

    private var matchBadge: some View {
        VStack(spacing: 0) {
            Text("\(item.matchScore)%")
                .font(AppFont.bodySemibold)
                .foregroundStyle(.white)
            Text("匹配")
                .font(AppFont.caption2)
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(width: 52, height: 52)
        .background(AppColor.aiGradient)
        .clipShape(Circle())
    }
}

// MARK: - Preview

#Preview("AI 推荐") {
    ScrollView {
        DashboardRecommendationSection(
            recommendations: DashboardOverview.mock.recommendations,
            onViewReason: { _ in }
        )
        .padding(.vertical, AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
