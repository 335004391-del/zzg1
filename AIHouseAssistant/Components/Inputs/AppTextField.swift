import SwiftUI

/// 标准文本输入框 — 带标签、错误提示、焦点状态、清空按钮
struct AppTextField: View {

    let label:        String
    let placeholder:  String
    @Binding var text: String
    var leadingIcon:  String?  = nil
    var errorMessage: String?  = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var submitLabel: SubmitLabel = .done
    var onSubmit:    (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if !label.isEmpty {
                fieldLabel
            }
            inputRow
            if let msg = errorMessage, !msg.isEmpty {
                errorRow(msg)
            }
        }
    }

    // MARK: - 子视图

    private var fieldLabel: some View {
        Text(label)
            .font(AppFont.captionMedium)
            .foregroundStyle(AppColor.textSecondary)
    }

    private var inputRow: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon = leadingIcon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(isFocused ? AppColor.primary : AppColor.textLight)
                    .animation(AppAnimation.fast, value: isFocused)
            }

            TextField(placeholder, text: $text)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .submitLabel(submitLabel)
                .onSubmit { onSubmit?() }
                .focused($isFocused)

            if !text.isEmpty {
                clearButton
            }
        }
        .padding(.horizontal, AppSpacing.base)
        .frame(height: 48)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(borderOverlay)
        .animation(AppAnimation.fast, value: isFocused)
        .animation(AppAnimation.fast, value: errorMessage)
    }

    private var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AppColor.placeholder)
        }
        .buttonStyle(.plain)
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: AppRadius.md)
            .stroke(borderColor, lineWidth: isFocused || errorMessage != nil ? 1.5 : 1)
    }

    private func errorRow(_ message: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 12))
            Text(message)
                .font(AppFont.caption)
        }
        .foregroundStyle(AppColor.error)
    }

    private var borderColor: Color {
        if let msg = errorMessage, !msg.isEmpty { return AppColor.error }
        return isFocused ? AppColor.primary : AppColor.border
    }
}

// MARK: - Preview

#Preview("文本输入框") {
    VStack(spacing: AppSpacing.lg) {
        AppTextField(label: "客户姓名", placeholder: "请输入客户姓名",
                     text: .constant(""), leadingIcon: "person")
        AppTextField(label: "手机号", placeholder: "请输入手机号",
                     text: .constant("138xxxx8888"), leadingIcon: "phone",
                     keyboardType: .phonePad)
        AppTextField(label: "邮箱", placeholder: "请输入邮箱",
                     text: .constant(""), leadingIcon: "envelope",
                     errorMessage: "邮箱格式不正确")
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
