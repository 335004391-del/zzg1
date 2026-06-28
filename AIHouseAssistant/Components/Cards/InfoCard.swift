import SwiftUI

/// 信息卡片 — 展示图标 + 标题 + 值 + 可选副标题
/// 用于客户详情、房源属性等键值展示场景
struct InfoCard: View {

    let icon:      String
    let iconColor: Color
    let title:     String
    let value:     String
    var subtitle:  String? = nil
    var badge:     String? = nil
    var action:    (() -> Void)? = nil

    var body: some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                iconArea
                textArea
                Spacer(minLength: 0)
                if let badge {
                    TagView(text: badge, style: .info)
                }
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColor.textLight)
                }
            }
        }
        .onTapGesture { action?() }
    }

    private var iconArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .fill(iconColor.opacity(0.12))
                .frame(width: 40, height: 40)
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
        }
    }

    private var textArea: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
            if let sub = subtitle {
                Text(sub)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
            }
        }
    }
}

// MARK: - Preview

#Preview("信息卡片") {
    VStack(spacing: AppSpacing.sm) {
        InfoCard(icon: "person.fill", iconColor: AppColor.primary,
                 title: "客户姓名", value: "张三丰")
        InfoCard(icon: "phone.fill", iconColor: AppColor.success,
                 title: "联系电话", value: "138 0000 8888",
                 subtitle: "上次联系：3天前", action: {})
        InfoCard(icon: "yensign.circle.fill", iconColor: AppColor.warning,
                 title: "购房预算", value: "200 ~ 300 万",
                 badge: "已确认", action: {})
    }
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
