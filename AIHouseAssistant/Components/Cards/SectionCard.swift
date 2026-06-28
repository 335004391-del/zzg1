import SwiftUI

/// Section 卡片 — 带标题、可选折叠、右侧操作按钮
struct SectionCard<Content: View>: View {

    let title:      String
    var subtitle:   String?  = nil
    var icon:       String?  = nil
    var actionTitle: String? = nil
    var isCollapsible: Bool  = false
    var onAction:   (() -> Void)? = nil
    @ViewBuilder let content: () -> Content

    @State private var isExpanded = true

    var body: some View {
        CardView(padding: 0) {
            VStack(spacing: 0) {
                headerRow
                if !isCollapsible || isExpanded {
                    Divider().foregroundStyle(AppColor.divider)
                    content()
                        .padding(AppSpacing.base)
                        .transition(AppAnimation.cardTransition)
                }
            }
        }
        .animation(AppAnimation.cardToggle, value: isExpanded)
    }

    private var headerRow: some View {
        HStack(spacing: AppSpacing.sm) {
            if let iconName = icon {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColor.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                if let sub = subtitle {
                    Text(sub)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            Spacer()

            if let actionTitle {
                Button(action: { onAction?() }) {
                    Text(actionTitle)
                        .font(AppFont.captionMedium)
                        .foregroundStyle(AppColor.primary)
                }
                .buttonStyle(.plain)
            }

            if isCollapsible {
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColor.textLight)
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
                    .onTapGesture { isExpanded.toggle() }
            }
        }
        .padding(AppSpacing.base)
        .contentShape(Rectangle())
        .onTapGesture {
            if isCollapsible { isExpanded.toggle() }
        }
    }
}

// MARK: - Preview

#Preview("Section 卡片") {
    VStack(spacing: AppSpacing.md) {
        SectionCard(title: "基本信息", icon: "person.crop.circle",
                    actionTitle: "编辑") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("姓名：张三丰").font(AppFont.body)
                Text("电话：138 0000 8888").font(AppFont.body)
                Text("预算：200~300万").font(AppFont.body)
            }
            .foregroundStyle(AppColor.textPrimary)
        }

        SectionCard(title: "购房需求", subtitle: "点击展开查看",
                    icon: "list.bullet.clipboard", isCollapsible: true) {
            Text("三房两厅，学区房，靠近地铁。")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
        }
    }
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
}
