import SwiftUI

/// 首页顶部导航 —— 左侧时间+问候语，右侧通知按钮+头像
/// 纯展示组件，交互通过闭包回调，便于复用与 Preview
struct DashboardHeaderView: View {

    /// 当前时间（HH:mm）
    let time: String
    /// 问候语（如 "早上好，张经理"）
    let greeting: String
    /// 点击通知
    var onTapNotification: () -> Void
    /// 点击头像（进入"我的"）
    var onTapAvatar: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {

            // 左侧：时间 + 问候语
            VStack(alignment: .leading, spacing: 2) {
                Text(time)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
                Text(greeting)
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
            }

            Spacer()

            // 右侧：通知按钮
            Button(action: onTapNotification) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(AppColor.surface)
                        .clipShape(Circle())
                    // 未读红点
                    Circle()
                        .fill(AppColor.error)
                        .frame(width: 8, height: 8)
                        .offset(x: -4, y: 4)
                }
            }
            .buttonStyle(.plain)

            // 右侧：头像
            Button(action: onTapAvatar) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(AppColor.primary)
                    .background(Circle().fill(AppColor.card))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview("顶部导航") {
    DashboardHeaderView(
        time: "09:24",
        greeting: "早上好，张经理",
        onTapNotification: {},
        onTapAvatar: {}
    )
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
