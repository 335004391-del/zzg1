import SwiftUI

/// 数字输入框 — 带步进加减按钮，可设最大最小值
struct NumberField: View {

    let label:    String
    let unit:     String
    @Binding var value: Double
    var minValue: Double = 0
    var maxValue: Double = Double.greatestFiniteMagnitude
    var step:     Double = 1
    var format:   String = "%.0f"
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool
    @State private var inputText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if !label.isEmpty {
                Text(label)
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.textSecondary)
            }
            inputRow
            if let msg = errorMessage, !msg.isEmpty {
                Text(msg)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.error)
            }
        }
        .onAppear { inputText = formatted(value) }
    }

    private var inputRow: some View {
        HStack(spacing: 0) {
            stepButton(icon: "minus", action: decrement)
                .disabled(value <= minValue)

            Divider().frame(height: 24)

            TextField("", text: $inputText)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .onChange(of: inputText) { _, newVal in
                    if let d = Double(newVal) {
                        value = min(maxValue, max(minValue, d))
                    }
                }
                .onChange(of: isFocused) { _, focused in
                    if !focused { inputText = formatted(value) }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, AppSpacing.sm)

            if !unit.isEmpty {
                Text(unit)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
                    .padding(.trailing, AppSpacing.sm)
            }

            Divider().frame(height: 24)

            stepButton(icon: "plus", action: increment)
                .disabled(value >= maxValue)
        }
        .frame(height: 48)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(isFocused ? AppColor.primary : AppColor.border,
                        lineWidth: isFocused ? 1.5 : 1)
        )
        .animation(AppAnimation.fast, value: isFocused)
    }

    private func stepButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 44, height: 48)
        }
        .buttonStyle(.plain)
    }

    private func increment() {
        value = min(maxValue, value + step)
        inputText = formatted(value)
    }

    private func decrement() {
        value = max(minValue, value - step)
        inputText = formatted(value)
    }

    private func formatted(_ v: Double) -> String {
        String(format: format, v)
    }
}

// MARK: - Preview

#Preview("数字输入框") {
    VStack(spacing: AppSpacing.lg) {
        NumberField(label: "预算（万元）", unit: "万", value: .constant(200),
                    minValue: 50, maxValue: 5000, step: 10)
        NumberField(label: "面积（㎡）", unit: "㎡", value: .constant(90),
                    minValue: 30, maxValue: 500, step: 5)
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
