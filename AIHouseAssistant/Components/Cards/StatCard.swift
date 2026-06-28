import SwiftUI

/// 统计数字卡片 — 用于 Dashboard 数据展示
struct StatCard: View {

    let title:   String
    let value:   String
    var unit:    String = ""
    var icon:    String? = nil
    var trend:   StatTrend? = nil
    var color:   Color = AppColor.primary
    var action:  (() -> Void)? = nil

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                topRow
                valueRow
                if let trend {
                    trendRow(trend)
                }
            }
        }
        .onTapGesture { action?() }
    }

    // MARK: - 子视图

    private var topRow: some View {
        HStack {
            if let iconName = icon {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(color)
                }
            }
            Text(title)
                .font(AppFont.label)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            if action != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.textLight)
            }
        }
    }

    private var valueRow: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text(value)
                .font(AppFont.display)
                .foregroundStyle(AppColor.textPrimary)
            if !unit.isEmpty {
                Text(unit)
                    .font(AppFont.callout)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    private func trendRow(_ trend: StatTrend) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: trend.isUp ? "arrow.up.right" : "arrow.down.right")
                .font(.system(size: 11, weight: .semibold))
            Text(trend.label)
                .font(AppFont.caption)
        }
        .foregroundStyle(trend.isUp ? AppColor.success : AppColor.error)
    }
}

// MARK: - 趋势数据

struct StatTrend {
    let label: String
    let isUp:  Bool

    static func up(_ label: String)   -> StatTrend { StatTrend(label: label, isUp: true) }
    static func down(_ label: String) -> StatTrend { StatTrend(label: label, isUp: false) }
}

// MARK: - Preview

#Preview("统计卡片") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
        StatCard(title: "本月客户", value: "128", unit: "人",
                 icon: "person.2.fill", trend: .up("+12 较上月"), color: AppColor.primary)
        StatCard(title: "在售房源", value: "56", unit: "套",
                 icon: "house.fill", trend: .down("-3 较上月"), color: AppColor.secondary)
        StatCard(title: "成交套数", value: "8", unit: "套",
                 icon: "checkmark.seal.fill", trend: .up("+2 较上月"), color: AppColor.success)
        StatCard(title: "匹配成功率", value: "73", unit: "%",
                 icon: "chart.pie.fill", color: AppColor.warning)
    }
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
