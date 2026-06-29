import SwiftUI

/// 最新房源 Section —— 标题 + 横向滚动房源卡片
struct DashboardHousesSection: View {

    /// 房源列表
    let houses: [House]
    /// 点击某房源（进入详情占位）
    var onTapHouse: (String) -> Void
    /// 点击「查看全部」
    var onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // 标题行
            DashboardSectionHeader(
                title: "最新房源",
                icon: "building.2",
                actionTitle: "查看全部",
                onAction: onViewAll
            )

            // 横向滚动卡片
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(houses) { house in
                        DashboardHouseCard(house: house) {
                            onTapHouse(house.id)
                        }
                        .frame(width: 260)
                    }
                }
                .padding(.horizontal, AppSpacing.base)
            }
        }
    }
}

// MARK: - 单个房源卡片

private struct DashboardHouseCard: View {

    let house: House
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView(padding: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    imagePlaceholder
                    infoSection
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - 图片占位（图片为远程 URL，此处用渐变占位）

    private var imagePlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [AppColor.primary.opacity(0.25), AppColor.secondary.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "photo")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(AppColor.card)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topLeading) {
            TagView(text: house.status.displayName, style: .primary, size: .small)
                .padding(AppSpacing.sm)
        }
    }

    // MARK: - 信息区

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // 小区名称
            Text(house.community)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            // 面积 · 户型
            Text("\(house.layoutDescription) · \(house.areaDescription)")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            // 标签
            HStack(spacing: AppSpacing.xs) {
                ForEach(derivedTags, id: \.0) { label, icon in
                    TagView(text: label, style: .info, size: .small, icon: icon)
                }
            }

            // 价格
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(house.priceDescription)
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.error)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 由房源属性派生展示标签（学区 / 地铁 / 精装修）
    private var derivedTags: [(String, String)] {
        var tags: [(String, String)] = []
        if house.schoolInfo != nil || house.tags.contains(.school) {
            tags.append(("学区", "graduationcap"))
        }
        if house.hasSubway || house.tags.contains(.subway) {
            tags.append(("地铁", "tram.fill"))
        }
        if house.decoration == .fine || house.decoration == .luxury {
            tags.append(("精装修", "paintbrush"))
        }
        return Array(tags.prefix(3))
    }
}

// MARK: - Preview

#Preview("最新房源") {
    ScrollView {
        DashboardHousesSection(
            houses: MockData.houses,
            onTapHouse: { _ in },
            onViewAll: {}
        )
        .padding(.vertical, AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
