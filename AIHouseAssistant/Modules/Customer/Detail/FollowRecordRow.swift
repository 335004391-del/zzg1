import SwiftUI

/// 跟进记录行 —— 展示单条跟进记录
struct FollowRecordRow: View {

    let record: FollowRecord

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // 类型图标
            ZStack {
                Circle()
                    .fill(AppColor.primaryLight)
                    .frame(width: 36, height: 36)
                Image(systemName: record.followType.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.primary)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(record.followType.displayName)
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Text(dateText)
                        .font(AppFont.caption2)
                        .foregroundStyle(AppColor.textLight)
                }

                Text(record.content)
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let feedback = record.customerFeedback {
                    Text("客户反馈：\(feedback)")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.info)
                }

                if let plan = record.nextFollowPlan {
                    Label(plan, systemImage: "calendar.badge.clock")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textLight)
                }
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 HH:mm"
        return formatter.string(from: record.createdAt)
    }
}

// MARK: - Preview

#Preview("跟进记录行") {
    VStack(spacing: 0) {
        FollowRecordRow(record: MockData.followRecord1)
        Divider()
    }
    .padding(AppSpacing.base)
    .background(AppColor.card)
}
