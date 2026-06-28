import SwiftUI

// MARK: - 确认对话框数据

struct ConfirmDialogConfig {
    let title:        String
    let message:      String
    let confirmTitle: String
    let cancelTitle:  String
    let confirmVariant: AppButtonVariant
    let onConfirm:    () -> Void
    let onCancel:     (() -> Void)?

    init(
        title:          String,
        message:        String,
        confirmTitle:   String         = "确认",
        cancelTitle:    String         = "取消",
        confirmVariant: AppButtonVariant = .primary,
        onConfirm:      @escaping () -> Void,
        onCancel:       (() -> Void)?  = nil
    ) {
        self.title          = title
        self.message        = message
        self.confirmTitle   = confirmTitle
        self.cancelTitle    = cancelTitle
        self.confirmVariant = confirmVariant
        self.onConfirm      = onConfirm
        self.onCancel       = onCancel
    }

    /// 危险操作预设（删除、清空等）
    static func destructive(
        title:   String,
        message: String,
        confirmTitle: String = "删除",
        onConfirm: @escaping () -> Void
    ) -> ConfirmDialogConfig {
        ConfirmDialogConfig(
            title:          title,
            message:        message,
            confirmTitle:   confirmTitle,
            confirmVariant: .danger,
            onConfirm:      onConfirm
        )
    }
}

// MARK: - 确认对话框 ViewModifier

struct ConfirmDialogModifier: ViewModifier {

    @Binding var config: ConfirmDialogConfig?

    func body(content: Content) -> some View {
        content
            .overlay {
                if let cfg = config {
                    dialogBackground
                    dialogPanel(cfg)
                }
            }
            .animation(AppAnimation.modal, value: config != nil)
    }

    private var dialogBackground: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(AppAnimation.fadeTransition)
    }

    private func dialogPanel(_ cfg: ConfirmDialogConfig) -> some View {
        VStack(spacing: 0) {
            // 内容区
            VStack(spacing: AppSpacing.md) {
                Text(cfg.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text(cfg.message)
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(AppSpacing.xl)

            Divider().foregroundStyle(AppColor.divider)

            // 按钮区
            HStack(spacing: 0) {
                cancelButton(cfg)
                Divider().frame(height: 48).foregroundStyle(AppColor.divider)
                confirmButton(cfg)
            }
        }
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .appShadow(AppShadow.popup)
        .padding(.horizontal, AppSpacing.xxxl)
        .transition(AppAnimation.popupTransition)
    }

    private func cancelButton(_ cfg: ConfirmDialogConfig) -> some View {
        Button {
            cfg.onCancel?()
            config = nil
        } label: {
            Text(cfg.cancelTitle)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.plain)
    }

    private func confirmButton(_ cfg: ConfirmDialogConfig) -> some View {
        Button {
            cfg.onConfirm()
            config = nil
        } label: {
            Text(cfg.confirmTitle)
                .font(AppFont.bodySemibold)
                .foregroundStyle(cfg.confirmVariant == .danger ? AppColor.error : AppColor.primary)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View 扩展

extension View {
    func confirmDialog(config: Binding<ConfirmDialogConfig?>) -> some View {
        modifier(ConfirmDialogModifier(config: config))
    }
}

// MARK: - Preview

#Preview("确认对话框") {
    @Previewable @State var normalDialog:  ConfirmDialogConfig? = nil
    @Previewable @State var deleteDialog:  ConfirmDialogConfig? = nil

    VStack(spacing: AppSpacing.lg) {
        AppButton.outline("普通确认") {
            normalDialog = ConfirmDialogConfig(
                title: "确认提交",
                message: "提交后数据将同步至云端，确认继续？",
                onConfirm: {}
            )
        }
        AppButton.danger("删除确认") {
            deleteDialog = .destructive(
                title: "删除客户",
                message: "删除后该客户所有数据将被清除，此操作不可撤销。",
                onConfirm: {}
            )
        }
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
    .confirmDialog(config: $normalDialog)
    .confirmDialog(config: $deleteDialog)
}
