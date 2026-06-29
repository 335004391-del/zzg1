import SwiftUI

/// 通用「敬请期待」占位页 —— 导航框架阶段所有页面的统一占位
/// 采用 Apple + Notion + Linear 极简风格，支持深色模式
struct ComingSoonView: View {

    /// 页面标题
    let title: String
    /// 主图标（SF Symbol）
    let icon: String
    /// 副标题（可选，用于展示传入的参数，验证类型安全传参）
    var subtitle: String? = nil
    /// 是否展示「下拉关闭」提示（全屏弹层场景）
    var showsCloseHint: Bool = false

    /// 入场动画开关
    @State private var isAppeared = false

    var body: some View {
        ZStack {
            AppColor.background
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                // 图标圆形容器
                ZStack {
                    Circle()
                        .fill(AppColor.primaryLight)
                        .frame(width: 96, height: 96)

                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(AppColor.primary)
                }
                .scaleEffect(isAppeared ? 1 : 0.85)
                .opacity(isAppeared ? 1 : 0)

                // 标题
                VStack(spacing: AppSpacing.sm) {
                    Text(title)
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textPrimary)

                    Text("敬请期待")
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textSecondary)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textLight)
                            .padding(.top, AppSpacing.xs)
                    }
                }
                .opacity(isAppeared ? 1 : 0)

                Spacer()

                // 全屏弹层关闭提示
                if showsCloseHint {
                    Text("下拉关闭")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textLight)
                        .padding(.bottom, AppSpacing.xl)
                }
            }
            .padding(AppSpacing.xl)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(AppAnimation.cardToggle) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview("浅色") {
    NavigationStack {
        ComingSoonView(title: "客户列表", icon: "person.2.fill")
    }
}

#Preview("带参数 / 深色") {
    NavigationStack {
        ComingSoonView(title: "客户详情", icon: "person.text.rectangle.fill",
                       subtitle: "客户 ID：1001")
    }
    .preferredColorScheme(.dark)
}
