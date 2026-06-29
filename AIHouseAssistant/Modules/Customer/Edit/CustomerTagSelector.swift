import SwiftUI

/// 客户标签多选器 —— 支持多选，样式与 Design System 一致
struct CustomerTagSelector: View {

    @Binding var selected: [CustomerTag]

    /// 可选标签（排除"不限"）
    private let options = CustomerTag.allCases.filter { $0 != .any }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 84), spacing: AppSpacing.sm)],
                  alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(options) { tag in
                let isOn = selected.contains(tag)
                Button { toggle(tag) } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: tag.icon)
                            .font(.system(size: 11, weight: .medium))
                        Text(tag.displayName)
                            .font(AppFont.captionMedium)
                    }
                    .foregroundStyle(isOn ? .white : AppColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                    .background(isOn ? AppColor.primary : AppColor.card)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(isOn ? .clear : AppColor.border, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(_ tag: CustomerTag) {
        if let index = selected.firstIndex(of: tag) {
            selected.remove(at: index)
        } else {
            selected.append(tag)
        }
    }
}

// MARK: - Preview

#Preview("标签选择器") {
    @Previewable @State var tags: [CustomerTag] = [.school, .subway]
    return CustomerTagSelector(selected: $tags)
        .padding(AppSpacing.base)
        .background(AppColor.backgroundAlt)
}
