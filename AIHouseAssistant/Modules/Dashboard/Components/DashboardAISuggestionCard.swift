import SwiftUI

/// AI 今日建议卡片 —— 优先联系客户 + 成交概率 + 推荐原因 + 操作按钮
struct DashboardAISuggestionCard: View {

    /// AI 建议数据
    let suggestion: DashboardAISuggestion
    /// 立即联系
    var onContact: () -> Void
    /// 稍后提醒
    var onRemindLater: () -> Void

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.base) {
                header
                Divider().foregroundStyle(AppColor.divider)
                customerRow
                reasonsView
                actionButtons
            }
        }
    }

    // MARK: - 标题

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColor.aiGradient)
            Text("AI 今日建议")
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            TagView(text: "智能推荐", style: .ai, size: .small)
        }
    }

    // MARK: - 客户与成交概率

    private var customerRow: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("今天建议优先联系")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Text(suggestion.customerName)
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Spacer()

            // 成交概率
            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                Text("成交概率")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                Text("\(suggestion.dealProbability)%")
                    .font(AppFont.displayMedium)
                    .foregroundStyle(AppColor.success)
            }
        }
    }

    // MARK: - 推荐原因

    private var reasonsView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("推荐原因")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            ForEach(Array(suggestion.reasons.enumerated()), id: \.offset) { _, reason in
                HStack(alignment: .top, spacing: AppSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColor.aiPurple)
                    Text(reason)
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColor.aiPurple.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    // MARK: - 操作按钮

    private var actionButtons: some View {
        HStack(spacing: AppSpacing.md) {
            AppButton(title: "立即联系", icon: "phone.fill",
                      variant: .primary, isFullWidth: true, action: onContact)
            AppButton(title: "稍后提醒", icon: "clock",
                      variant: .outline, isFullWidth: true, action: onRemindLater)
        }
    }
}

// MARK: - Preview

#Preview("AI 今日建议") {
    DashboardAISuggestionCard(
        suggestion: DashboardOverview.mock.aiSuggestion,
        onContact: {},
        onRemindLater: {}
    )
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
