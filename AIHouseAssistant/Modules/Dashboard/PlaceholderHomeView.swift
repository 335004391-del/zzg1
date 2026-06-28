import SwiftUI

/// 首页占位视图 — Task001 阶段仅展示项目初始化状态
struct PlaceholderHomeView: View {

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [
                    Color(hex: "#0F2027"),
                    Color(hex: "#203A43"),
                    Color(hex: "#2C5364")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {

                Spacer()

                // 图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "house.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#56CCF2"), Color(hex: "#2F80ED")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .themeShadow(Theme.Shadow.medium)

                // 标题
                VStack(spacing: Theme.Spacing.sm) {
                    Text(AppConstants.appName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Version \(AppConstants.appVersion)")
                        .font(Theme.Font.callout)
                        .foregroundColor(.white.opacity(0.6))
                }

                // 状态标签
                statusBadge

                Spacer()

                // 底部模块列表
                moduleStatusGrid

                Spacer()
                    .frame(height: Theme.Spacing.xxl)
            }
            .padding(.horizontal, Theme.Spacing.xl)
        }
        .navigationBarHidden(true)
    }

    // MARK: - 子视图

    /// 初始化成功标签
    private var statusBadge: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Circle()
                .fill(Color(hex: "#27AE60"))
                .frame(width: 8, height: 8)

            Text("Project Initialized")
                .font(Theme.Font.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, Theme.Spacing.base)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Color.white.opacity(0.12))
        .clipShape(Capsule())
    }

    /// 模块状态网格
    private var moduleStatusGrid: some View {
        let modules: [(String, String, Bool)] = [
            ("配置中心", "gearshape.fill", true),
            ("日志系统", "doc.text.fill", true),
            ("网络层", "wifi", true),
            ("主题系统", "paintpalette.fill", true),
            ("依赖注入", "arrow.triangle.branch", true),
            ("本地存储", "internaldrive.fill", true),
        ]

        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: Theme.Spacing.md
        ) {
            ForEach(modules, id: \.0) { name, icon, done in
                ModuleStatusCell(name: name, icon: icon, isDone: done)
            }
        }
    }
}

// MARK: - 模块状态卡片

private struct ModuleStatusCell: View {
    let name:   String
    let icon:   String
    let isDone: Bool

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: Theme.IconSize.medium))
                .foregroundColor(isDone ? Color(hex: "#56CCF2") : .white.opacity(0.3))

            Text(name)
                .font(Theme.Font.caption1)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(isDone ? Color(hex: "#27AE60") : .white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.md)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
    }
}

#Preview {
    NavigationStack {
        PlaceholderHomeView()
    }
}
