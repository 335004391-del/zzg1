import SwiftUI

/// 房源标签多选器
struct HouseTagSelector: View {

    @Binding var selected: [HouseTag]

    private let options = HouseTag.allCases

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: AppSpacing.sm)],
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
                    .overlay(Capsule().stroke(isOn ? .clear : AppColor.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(_ tag: HouseTag) {
        if let index = selected.firstIndex(of: tag) {
            selected.remove(at: index)
        } else {
            selected.append(tag)
        }
    }
}

// MARK: - Preview

#Preview("房源标签选择器") {
    @Previewable @State var tags: [HouseTag] = [.school, .subway]
    return HouseTagSelector(selected: $tags)
        .padding(AppSpacing.base)
        .background(AppColor.backgroundAlt)
}
