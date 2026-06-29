import SwiftUI

/// 快捷功能 —— 两行 Grid 入口（客户/房源/AI匹配/导入/待办/排行/驾驶舱/设置）
struct DashboardQuickActionsGrid: View {

    /// 点击某个快捷入口
    var onTap: (DashboardQuickAction) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.md), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            DashboardSectionHeader(title: "快捷功能", icon: "square.grid.2x2")

            CardView {
                LazyVGrid(columns: columns, spacing: AppSpacing.lg) {
                    ForEach(DashboardQuickAction.allCases) { action in
                        DashboardQuickActionCell(action: action) {
                            onTap(action)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.base)
        }
    }
}

// MARK: - 单个快捷入口

private struct DashboardQuickActionCell: View {

    let action: DashboardQuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(action.accent.softBackground)
                        .frame(width: 48, height: 48)
                    Image(systemName: action.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(action.accent.color)
                }
                Text(action.title)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(AppQuickActionPressStyle())
    }
}

/// 快捷入口按压动效（Spring）
private struct AppQuickActionPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("快捷功能") {
    DashboardQuickActionsGrid(onTap: { _ in })
        .padding(.vertical, AppSpacing.base)
        .background(AppColor.backgroundAlt)
}
