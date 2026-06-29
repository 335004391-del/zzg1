import SwiftUI

/// 首页欢迎区域 —— 欢迎语 + 今日日期 + 天气占位
struct DashboardWelcomeCard: View {

    /// 今日日期文案
    let todayText: String

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {

                // 欢迎语
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("欢迎回来 👋")
                        .font(AppFont.title3)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("今天也是成交的一天！")
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Divider().foregroundStyle(AppColor.divider)

                // 日期 + 天气占位
                HStack(spacing: AppSpacing.base) {
                    Label(todayText, systemImage: "calendar")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)

                    Spacer()

                    // 天气位置预留
                    Label("天气待接入", systemImage: "cloud.sun")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textLight)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("欢迎区域") {
    DashboardWelcomeCard(todayText: "2026年6月29日 星期一")
        .padding(AppSpacing.base)
        .background(AppColor.backgroundAlt)
}
