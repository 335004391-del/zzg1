import SwiftUI

/// 客户 AI 画像卡片 —— Mock 数据，展示 AI 分析要点与成交概率
struct CustomerAIProfileCard: View {

    let points: [String]
    let dealProbability: Int
    let aiScore: Int

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.base) {
                header
                Divider().foregroundStyle(AppColor.divider)
                metricsRow
                pointsView
            }
        }
    }

    // MARK: - 标题

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.aiGradient)
            Text("AI 客户画像")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            TagView(text: "Mock 分析", style: .ai, size: .small)
        }
    }

    // MARK: - 指标行：成交概率 + AI 评分

    private var metricsRow: some View {
        HStack(spacing: AppSpacing.base) {
            metricBox(title: "成交概率", value: "\(dealProbability)%",
                      color: DealProbabilityStyle.color(dealProbability))
            metricBox(title: "AI 评分", value: "\(aiScore)",
                      color: AppColor.aiPurple)
        }
    }

    private func metricBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.displayMedium)
                .foregroundStyle(color)
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    // MARK: - 要点

    private var pointsView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.aiPurple)
                        .padding(.top, 2)
                    Text(point)
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("AI 画像卡片") {
    CustomerAIProfileCard(
        points: ["预算 200~320 万，购买力稳定", "偏好地铁沿线，看重通勤便利",
                 "关注学区，可能有子女教育需求"],
        dealProbability: 86,
        aiScore: 82
    )
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
