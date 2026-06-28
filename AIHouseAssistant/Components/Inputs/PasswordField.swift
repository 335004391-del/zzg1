import SwiftUI

/// 密码输入框 — 带显示/隐藏切换按钮
struct PasswordField: View {

    let label:       String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool
    @State private var isVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if !label.isEmpty {
                Text(label)
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.textSecondary)
            }

            inputRow

            if let msg = errorMessage, !msg.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(msg)
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.error)
            }
        }
    }

    private var inputRow: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "lock")
                .font(.system(size: 16))
                .foregroundStyle(isFocused ? AppColor.primary : AppColor.textLight)
                .animation(AppAnimation.fast, value: isFocused)

            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }
            }
            .font(AppFont.body)
            .foregroundStyle(AppColor.textPrimary)
            .focused($isFocused)

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColor.textLight)
            }
            .buttonStyle(.plain)
            .animation(AppAnimation.fast, value: isVisible)
        }
        .padding(.horizontal, AppSpacing.base)
        .frame(height: 48)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(
                    errorMessage != nil ? AppColor.error : (isFocused ? AppColor.primary : AppColor.border),
                    lineWidth: isFocused || errorMessage != nil ? 1.5 : 1
                )
        )
        .animation(AppAnimation.fast, value: isFocused)
    }
}

// MARK: - Preview

#Preview("密码输入框") {
    VStack(spacing: AppSpacing.lg) {
        PasswordField(label: "密码", placeholder: "请输入密码", text: .constant(""))
        PasswordField(label: "密码", placeholder: "请输入密码",
                      text: .constant("123456"), errorMessage: "密码长度不足 8 位")
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
