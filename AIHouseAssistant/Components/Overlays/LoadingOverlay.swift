import SwiftUI

// MARK: - 全屏 Loading 遮罩

/// 全屏加载遮罩 — 操作进行中时阻断交互
struct LoadingOverlayModifier: ViewModifier {

    let isLoading: Bool
    var message:   String = "处理中…"

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.35)
                            .ignoresSafeArea()
                            .transition(AppAnimation.fadeTransition)

                        loadingPanel
                            .transition(AppAnimation.popupTransition)
                    }
                }
            }
            .animation(AppAnimation.modal, value: isLoading)
            .allowsHitTesting(!isLoading)
    }

    private var loadingPanel: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(AppColor.primary)
                .scaleEffect(1.2)

            Text(message)
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.horizontal, AppSpacing.xxxl)
        .padding(.vertical, AppSpacing.xl)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .appShadow(AppShadow.popup)
    }
}

// MARK: - AI 专属 Loading 遮罩

/// AI 分析进行中的特殊 Loading 样式
struct AILoadingOverlayModifier: ViewModifier {

    let isLoading: Bool
    var message:   String = "AI 分析中…"
    var submessage: String = "正在生成客户画像"

    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .transition(AppAnimation.fadeTransition)

                        aiPanel
                            .transition(AppAnimation.popupTransition)
                    }
                }
            }
            .animation(AppAnimation.modal, value: isLoading)
            .allowsHitTesting(!isLoading)
    }

    private var aiPanel: some View {
        VStack(spacing: AppSpacing.lg) {
            // AI 旋转图标
            ZStack {
                Circle()
                    .fill(AppColor.aiGradient.opacity(0.15))
                    .frame(width: 72, height: 72)

                Image(systemName: "sparkles")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(AppColor.aiGradient)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
            }

            VStack(spacing: AppSpacing.xs) {
                Text(message)
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.textPrimary)
                Text(submessage)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(.horizontal, AppSpacing.xxxl)
        .padding(.vertical, AppSpacing.xxl)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .appShadow(AppShadow.popup)
    }
}

// MARK: - View 扩展

extension View {
    /// 添加标准全屏 Loading 遮罩
    func loadingOverlay(isLoading: Bool, message: String = "处理中…") -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message))
    }

    /// 添加 AI 专属 Loading 遮罩
    func aiLoadingOverlay(
        isLoading: Bool,
        message: String = "AI 分析中…",
        submessage: String = "正在生成分析结果"
    ) -> some View {
        modifier(AILoadingOverlayModifier(
            isLoading: isLoading,
            message: message,
            submessage: submessage
        ))
    }
}

// MARK: - Preview

#Preview("Loading 遮罩") {
    @Previewable @State var isLoading    = false
    @Previewable @State var isAILoading  = false

    VStack(spacing: AppSpacing.lg) {
        AppButton.primary("显示标准 Loading") { isLoading = true }
        AppButton(title: "显示 AI Loading", variant: .outline, action: { isAILoading = true })
        AppButton(title: "停止", variant: .secondary, action: {
            isLoading   = false
            isAILoading = false
        })
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
    .loadingOverlay(isLoading: isLoading, message: "正在保存客户信息…")
    .aiLoadingOverlay(isLoading: isAILoading,
                      message: "AI 分析中…",
                      submessage: "正在匹配最优房源")
}
