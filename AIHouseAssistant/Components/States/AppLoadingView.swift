import SwiftUI

// MARK: - 全局 Loading 视图

/// 页面级加载视图 — 居中显示 Spinner + 可选文字
struct AppLoadingView: View {

    var message: String = "加载中…"
    var showMessage: Bool = true

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)
                .tint(AppColor.primary)
            if showMessage {
                Text(message)
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
        }
    }
}

// MARK: - 行内 Loading 视图（列表加载更多）

struct InlineLoadingView: View {

    var message: String = "正在加载更多…"

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(AppColor.textLight)
                .scaleEffect(0.8)
            Text(message)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }
}

// MARK: - 错误状态视图

/// 加载失败时显示的错误视图
struct ErrorStateView: View {

    var message: String = "加载失败，请重试"
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()

            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(AppColor.errorBg)
                        .frame(width: 80, height: 80)
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(AppColor.error)
                }

                VStack(spacing: AppSpacing.sm) {
                    Text("加载失败")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(message)
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }

                if let onRetry {
                    AppButton(title: "重新加载", icon: "arrow.clockwise",
                              variant: .outline, action: onRetry)
                }
            }
            .padding(.horizontal, AppSpacing.xxxl)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Loading 状态") {
    TabView {
        AppLoadingView()
            .tabItem { Label("Loading", systemImage: "hourglass") }
        ErrorStateView(message: "网络连接失败，请检查网络后重试", onRetry: {})
            .tabItem { Label("Error", systemImage: "xmark.circle") }
    }
    .background(AppColor.background)
}
