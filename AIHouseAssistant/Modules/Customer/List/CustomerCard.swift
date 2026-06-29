import SwiftUI

/// 客户卡片 —— 列表中单个客户的展示
struct CustomerCard: View {

    let customer: Customer
    /// 点击卡片（进入详情）
    var onTap: () -> Void
    /// 点击收藏星标
    var onToggleFavorite: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    topRow
                    infoRow
                    if !customer.tags.isEmpty { tagRow }
                    Divider().foregroundStyle(AppColor.divider)
                    bottomRow
                }
            }
        }
        .buttonStyle(CustomerCardPressStyle())
    }

    // MARK: - 顶部：头像 + 姓名 + 状态 + 收藏

    private var topRow: some View {
        HStack(spacing: AppSpacing.md) {
            // 头像
            Text(customer.avatarText)
                .font(AppFont.bodySemibold)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(AppColor.primary.gradient)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Text(customer.name)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    TagView(text: customer.status.displayName,
                            style: customer.status.tagStyle, size: .small)
                }
                Text(customer.phone)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            Spacer()

            // 收藏星标
            Button(action: onToggleFavorite) {
                Image(systemName: customer.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(customer.isFavorite ? AppColor.warning : AppColor.textLight)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 中部：预算 / 区域 / 目的

    private var infoRow: some View {
        HStack(spacing: AppSpacing.lg) {
            metric(icon: "yensign.circle", text: customer.budgetDescription)
            metric(icon: "mappin.and.ellipse", text: customer.primaryArea)
            metric(icon: customer.housePurpose.icon, text: customer.housePurpose.displayName)
        }
    }

    private func metric(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(AppColor.textLight)
            Text(text)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
                .lineLimit(1)
        }
    }

    // MARK: - 标签

    private var tagRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                ForEach(customer.tags) { tag in
                    TagView(text: tag.displayName, style: tag.tagStyle,
                            size: .small, icon: tag.icon)
                }
            }
        }
    }

    // MARK: - 底部：成交概率 / AI 评分 / 最近联系

    private var bottomRow: some View {
        HStack(spacing: AppSpacing.lg) {
            // 成交概率
            HStack(spacing: AppSpacing.xs) {
                Text("成交")
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColor.textLight)
                Text("\(customer.dealProbability)%")
                    .font(AppFont.captionMedium)
                    .foregroundStyle(DealProbabilityStyle.color(customer.dealProbability))
            }

            // AI 评分
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundStyle(AppColor.aiPurple)
                Text("\(customer.aiScore)")
                    .font(AppFont.captionMedium)
                    .foregroundStyle(AppColor.aiPurple)
            }

            Spacer()

            // 最近联系
            Text(customer.lastContactDescription)
                .font(AppFont.caption2)
                .foregroundStyle(AppColor.textLight)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColor.textLight)
        }
    }
}

// MARK: - 按压动效

private struct CustomerCardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("客户卡片") {
    ScrollView {
        VStack(spacing: AppSpacing.md) {
            CustomerCard(customer: MockData.customer1, onTap: {}, onToggleFavorite: {})
            CustomerCard(customer: MockCustomerFactory.generate(count: 1)[0],
                         onTap: {}, onToggleFavorite: {})
        }
        .padding(AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
