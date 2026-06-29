import SwiftUI

/// 房源 AI 分析卡片 —— Mock 数据，展示优点与成交速度预估
struct HouseAIAnalysisCard: View {

    let points: [String]
    let dealSpeed: String
    let aiScore: Int

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.base) {
                header
                Divider().foregroundStyle(AppColor.divider)
                advantagesView
                dealSpeedView
            }
        }
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.aiGradient)
            Text("AI 房源分析")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            TagView(text: "推荐度 \(aiScore)", style: .ai, size: .small)
        }
    }

    private var advantagesView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("核心优点")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColor.success)
                        .padding(.top, 1)
                    Text(point)
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
    }

    private var dealSpeedView: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "speedometer")
                .font(.system(size: 14))
                .foregroundStyle(AppColor.aiPurple)
            Text(dealSpeed)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.aiPurple)
            Spacer()
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.aiPurple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

// MARK: - Preview

#Preview("AI 房源分析") {
    HouseAIAnalysisCard(
        points: ["距离地铁约 350 米，通勤便利", "学区优质", "精装修交付，可拎包入住",
                 "户型 3室2厅1卫，105㎡，适合改善型家庭"],
        dealSpeed: "预计成交速度：快",
        aiScore: 88
    )
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
