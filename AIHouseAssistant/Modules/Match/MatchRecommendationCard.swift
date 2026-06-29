import SwiftUI

/// 匹配推荐卡片 —— 房源信息 + 匹配度 + 推荐理由 + 操作
struct MatchRecommendationCard: View {

    let recommendation: MatchRecommendation
    var onTapDetail: () -> Void
    var onToggleFavorite: () -> Void

    private var house: House { recommendation.house }

    var body: some View {
        CardView(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                cover
                content
            }
        }
    }

    // MARK: - 封面 + 匹配度

    private var cover: some View {
        ZStack(alignment: .topTrailing) {
            HouseCoverPalette.gradient(seed: house.coverSeed)
                .frame(height: 130)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(.white.opacity(0.85))
                )
            // 收藏
            Button(action: onToggleFavorite) {
                Image(systemName: recommendation.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(recommendation.isFavorite ? AppColor.error : .white)
                    .padding(AppSpacing.sm)
                    .background(.black.opacity(0.25))
                    .clipShape(Circle())
                    .padding(AppSpacing.sm)
            }
            .buttonStyle(.plain)
        }
        .overlay(alignment: .topLeading) {
            matchBadge.padding(AppSpacing.sm)
        }
    }

    private var matchBadge: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .bold))
            Text("\(recommendation.scoreInt) 分")
                .font(AppFont.captionMedium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 4)
        .background(recommendation.level.appColor)
        .clipShape(Capsule())
    }

    // MARK: - 内容

    private var content: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(house.title)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            HStack(alignment: .lastTextBaseline, spacing: AppSpacing.sm) {
                Text(house.priceDescription)
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.error)
                Text("\(house.layoutDescription) · \(house.areaDescription)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer()
                TagView(text: recommendation.level.displayName,
                        style: recommendation.level.tagStyle, size: .small)
            }

            // 推荐理由（前两条）
            if !recommendation.reasons.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    ForEach(Array(recommendation.reasons.prefix(2).enumerated()), id: \.offset) { _, reason in
                        HStack(alignment: .top, spacing: AppSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(AppColor.success)
                                .padding(.top, 1)
                            Text(reason)
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Divider().foregroundStyle(AppColor.divider)

            // 操作
            HStack(spacing: AppSpacing.md) {
                ShareLink(item: recommendation.shareText) {
                    Label("分享", systemImage: "square.and.arrow.up")
                        .font(AppFont.captionMedium)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                Button(action: onTapDetail) {
                    HStack(spacing: AppSpacing.xs) {
                        Text("查看详情")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.md)
    }
}

// MARK: - Preview

#Preview("推荐卡片") {
    let engine = MatchEngine()
    let rec = engine.evaluate(customer: MockData.customer1, house: MockData.house1, isFavorite: false)
    return ScrollView {
        MatchRecommendationCard(recommendation: rec, onTapDetail: {}, onToggleFavorite: {})
            .padding(AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
