import SwiftUI

/// 多行文本输入框 — 带字符计数、最大限制
struct TextArea: View {

    let label:       String
    let placeholder: String
    @Binding var text: String
    var maxLength:   Int    = 500
    var minHeight:   CGFloat = 100
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if !label.isEmpty {
                Text(label)
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.textSecondary)
            }
            inputArea
            bottomRow
        }
    }

    private var inputArea: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.placeholder)
                    .padding(.top, AppSpacing.md)
                    .padding(.leading, AppSpacing.base + 2)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .frame(minHeight: minHeight)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.sm)
                .onChange(of: text) { _, newVal in
                    if newVal.count > maxLength {
                        text = String(newVal.prefix(maxLength))
                    }
                }
        }
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

    private var bottomRow: some View {
        HStack {
            if let msg = errorMessage, !msg.isEmpty {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 12))
                    Text(msg)
                        .font(AppFont.caption)
                }
                .foregroundStyle(AppColor.error)
            }
            Spacer()
            Text("\(text.count) / \(maxLength)")
                .font(AppFont.caption)
                .foregroundStyle(text.count >= maxLength ? AppColor.warning : AppColor.placeholder)
        }
    }
}

// MARK: - Preview

#Preview("多行输入框") {
    VStack(spacing: AppSpacing.lg) {
        TextArea(label: "备注", placeholder: "请输入客户备注信息…",
                 text: .constant(""), maxLength: 200)
        TextArea(label: "需求描述", placeholder: "描述购房需求…",
                 text: .constant("客户需要三房两厅，预算200万，要求学区房。"),
                 maxLength: 300, errorMessage: "描述不能超过 300 字")
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
