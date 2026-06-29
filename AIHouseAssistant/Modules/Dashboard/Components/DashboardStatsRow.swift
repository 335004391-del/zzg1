import SwiftUI

/// 今日统计 —— 横向滚动统计卡片
struct DashboardStatsRow: View {

    /// 统计数据
    let stats: [DashboardStatItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.md) {
                ForEach(stats) { stat in
                    StatCard(
                        title: stat.title,
                        value: stat.value,
                        unit:  stat.unit,
                        icon:  stat.icon,
                        color: stat.accent.color
                    )
                    .frame(width: 160)
                }
            }
            .padding(.horizontal, AppSpacing.base)
        }
    }
}

// MARK: - Preview

#Preview("今日统计") {
    DashboardStatsRow(stats: DashboardOverview.mock.stats)
        .padding(.vertical, AppSpacing.base)
        .background(AppColor.backgroundAlt)
}
