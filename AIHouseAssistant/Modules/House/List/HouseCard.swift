import SwiftUI

/// 房源卡片 —— 列表中单套房源的展示
struct HouseCard: View {

    let house: House
    var onTap: () -> Void
    var onToggleFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    coverImage
                    infoSection
                }
            }
        }
        .buttonStyle(HouseCardPressStyle())
    }

    // MARK: - 封面（占位渐变 + 收藏 + 状态）

    private var coverImage: some View {
        ZStack {
            HouseCoverPalette.gradient(seed: house.coverSeed)
            Image(systemName: "building.2.fill")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay(alignment: .topLeading) {
            TagView(text: house.status.displayName, style: house.status.tagStyle, size: .small)
                .padding(AppSpacing.sm)
        }
        .overlay(alignment: .topTrailing) {
            Button(action: onToggleFavorite) {
                Image(systemName: house.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(house.isFavorite ? AppColor.error : .white)
                    .padding(AppSpacing.sm)
                    .background(.black.opacity(0.25))
                    .clipShape(Circle())
                    .padding(AppSpacing.sm)
            }
            .buttonStyle(.plain)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("\(house.images.count) 图")
                .font(AppFont.caption2)
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, 2)
                .background(.black.opacity(0.3))
                .clipShape(Capsule())
                .padding(AppSpacing.sm)
        }
    }

    // MARK: - 信息区

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(house.title)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            Text("\(house.community) · \(house.district)")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)

            // 价格
            HStack(alignment: .lastTextBaseline, spacing: AppSpacing.sm) {
                Text(house.priceDescription)
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.error)
                Text(house.unitPriceDescription)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
            }

            // 面积 / 户型 / 楼层 / 装修
            HStack(spacing: AppSpacing.md) {
                metric(house.layoutDescription)
                metric(house.areaDescription)
                metric(house.floorDescription)
                metric(house.decoration.displayName)
            }

            // 标签
            if !house.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(house.tags) { tag in
                            TagView(text: tag.displayName, style: tag.tagStyle,
                                    size: .small, icon: tag.icon)
                        }
                    }
                }
            }

            Divider().foregroundStyle(AppColor.divider)

            Text(house.updatedDescription)
                .font(AppFont.caption2)
                .foregroundStyle(AppColor.textLight)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func metric(_ text: String) -> some View {
        Text(text)
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textSecondary)
            .lineLimit(1)
    }
}

// MARK: - 按压动效

private struct HouseCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("房源卡片") {
    ScrollView {
        VStack(spacing: AppSpacing.md) {
            HouseCard(house: MockData.house1, onTap: {}, onToggleFavorite: {})
            HouseCard(house: MockHouseFactory.generate(count: 1)[0],
                      onTap: {}, onToggleFavorite: {})
        }
        .padding(AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
