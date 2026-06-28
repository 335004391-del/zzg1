import SwiftUI

/// 导航栏操作按钮数据模型
struct NavBarAction: Identifiable {
    let id    = UUID()
    let icon:  String
    let action: () -> Void
}

/// 统一自定义导航栏 — 支持标题、副标题、右侧多操作、搜索模式
struct AppNavigationBar: View {

    let title:       String
    var subtitle:    String?     = nil
    var showBack:    Bool        = false
    var trailingActions: [NavBarAction] = []
    var searchText:  Binding<String>?   = nil
    var onBack:      (() -> Void)?      = nil

    @State private var isSearching = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if showBack {
                backButton
            }

            if isSearching, let binding = searchText {
                SearchBar(placeholder: "搜索…", text: binding) {
                    withAnimation(AppAnimation.fast) { isSearching = false }
                }
            } else {
                titleArea
                Spacer()
                trailingButtons
            }
        }
        .padding(.horizontal, AppSpacing.base)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColor.background)
        .overlay(alignment: .bottom) {
            Divider().foregroundStyle(AppColor.divider)
        }
    }

    // MARK: - 子视图

    private var backButton: some View {
        Button(action: { onBack?() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColor.primary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }

    private var titleArea: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
            if let sub = subtitle {
                Text(sub)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var trailingButtons: some View {
        HStack(spacing: AppSpacing.xs) {
            // 如果有 searchText binding，显示搜索按钮
            if searchText != nil {
                iconButton(icon: "magnifyingglass") {
                    withAnimation(AppAnimation.fast) { isSearching = true }
                }
            }
            // 自定义操作按钮
            ForEach(trailingActions) { action in
                iconButton(icon: action.icon, action: action.action)
            }
        }
    }

    private func iconButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColor.primary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(AppPressNavStyle())
    }
}

private struct AppPressNavStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(AppColor.primary.opacity(configuration.isPressed ? 0.1 : 0))
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - 大标题导航栏（首页风格）

/// 首页大标题导航栏
struct AppLargeTitleBar: View {

    let title:    String
    var subtitle: String? = nil
    var trailingActions: [NavBarAction] = []

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 2) {
                if let sub = subtitle {
                    Text(sub)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Text(title)
                    .font(AppFont.titleLarge)
                    .foregroundStyle(AppColor.textPrimary)
            }
            Spacer()
            HStack(spacing: AppSpacing.xs) {
                ForEach(trailingActions) { action in
                    Button(action: action.action) {
                        Image(systemName: action.icon)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(AppColor.primary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(AppColor.surface))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, AppSpacing.base)
        .padding(.bottom, AppSpacing.sm)
    }
}

// MARK: - Preview

#Preview("导航栏") {
    VStack(spacing: 0) {
        AppNavigationBar(
            title: "客户管理",
            subtitle: "共 128 位客户",
            showBack: true,
            trailingActions: [
                NavBarAction(icon: "plus", action: {}),
                NavBarAction(icon: "ellipsis.circle", action: {})
            ],
            searchText: .constant(""),
            onBack: {}
        )

        Divider().padding(.top, AppSpacing.xl)

        AppLargeTitleBar(
            title: "客户列表",
            subtitle: "今天",
            trailingActions: [
                NavBarAction(icon: "bell", action: {}),
                NavBarAction(icon: "person.circle", action: {})
            ]
        )
        Spacer()
    }
    .background(AppColor.background)
}
