import SwiftUI

/// 匹配详情页 —— 客户需求 + 房源信息 + 评分详情 + 雷达图 + 推荐理由 / 不推荐原因
struct MatchDetailView: View {

    let customerId: String
    let houseId: String

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel: MatchDetailViewModel

    init(customerId: String, houseId: String) {
        self.customerId = customerId
        self.houseId = houseId
        _viewModel = State(initialValue: MatchDetailViewModel(customerId: customerId, houseId: houseId))
    }

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            content
        }
        .navigationTitle("匹配详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.onAppear(repository: container.matchRepository)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            AppLoadingView(message: "正在加载…")
        } else if let rec = viewModel.recommendation {
            detailScroll(rec)
        } else {
            ErrorStateView(message: viewModel.errorMessage ?? "未找到数据") {
                Task { await viewModel.onAppear(repository: container.matchRepository) }
            }
        }
    }

    private func detailScroll(_ rec: MatchRecommendation) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                scoreHeader(rec)
                radarCard(rec)
                breakdownCard(rec)
                requirementCard(rec)
                houseCard(rec)
                reasonCard(rec)
                if !rec.mismatchReasons.isEmpty {
                    mismatchCard(rec)
                }
                viewHouseButton(rec)
            }
            .padding(AppSpacing.base)
        }
    }

    // MARK: - 综合分头部

    private func scoreHeader(_ rec: MatchRecommendation) -> some View {
        CardView {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle().stroke(AppColor.surface, lineWidth: 8).frame(width: 96, height: 96)
                    Circle()
                        .trim(from: 0, to: rec.score.final / 100)
                        .stroke(rec.level.appColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 96, height: 96)
                    VStack(spacing: 0) {
                        Text("\(rec.scoreInt)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColor.textPrimary)
                        Text("分")
                            .font(AppFont.caption2)
                            .foregroundStyle(AppColor.textLight)
                    }
                }
                TagView(text: rec.level.displayName, style: rec.level.tagStyle)
                Text("\(rec.customer.name) × \(rec.house.community)")
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - 雷达图

    private func radarCard(_ rec: MatchRecommendation) -> some View {
        SectionCard(title: "匹配雷达", icon: "chart.dots.scatter") {
            MatchRadarChart(values: rec.score.breakdown.map { ($0.dimension.displayName, $0.value) })
        }
    }

    // MARK: - 评分详情

    private func breakdownCard(_ rec: MatchRecommendation) -> some View {
        SectionCard(title: "评分详情", icon: "list.number") {
            ScoreBreakdownView(score: rec.score)
        }
    }

    // MARK: - 客户需求

    private func requirementCard(_ rec: MatchRecommendation) -> some View {
        SectionCard(title: "客户需求", icon: "person.crop.circle") {
            VStack(spacing: AppSpacing.sm) {
                kv("预算", rec.customer.budgetDescription)
                kv("意向区域", rec.customer.preferredArea.isEmpty ? "不限" : rec.customer.preferredArea.joined(separator: "、"))
                kv("期望面积", rec.customer.areaDescription)
                kv("期望户型", rec.customer.roomsDescription)
                if !rec.customer.tags.isEmpty {
                    kv("标签", rec.customer.tags.map(\.displayName).joined(separator: "、"))
                }
            }
        }
    }

    // MARK: - 房源信息

    private func houseCard(_ rec: MatchRecommendation) -> some View {
        SectionCard(title: "房源信息", icon: "house") {
            VStack(spacing: AppSpacing.sm) {
                kv("总价", rec.house.priceDescription)
                kv("单价", rec.house.unitPriceDescription)
                kv("区域", "\(rec.house.city)\(rec.house.district)")
                kv("面积", rec.house.areaDescription)
                kv("户型", rec.house.layoutDescription)
                kv("朝向", rec.house.orientation.displayName)
                kv("装修", rec.house.decoration.displayName)
            }
        }
    }

    // MARK: - 推荐理由

    private func reasonCard(_ rec: MatchRecommendation) -> some View {
        SectionCard(title: "推荐理由", icon: "checkmark.seal") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(Array(rec.reasons.enumerated()), id: \.offset) { _, reason in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColor.success)
                        Text(reason)
                            .font(AppFont.bodySmall)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 不推荐原因

    private func mismatchCard(_ rec: MatchRecommendation) -> some View {
        SectionCard(title: "需注意", icon: "exclamationmark.triangle") {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(Array(rec.mismatchReasons.enumerated()), id: \.offset) { _, reason in
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColor.warning)
                        Text(reason)
                            .font(AppFont.bodySmall)
                            .foregroundStyle(AppColor.textPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 跳转房源

    private func viewHouseButton(_ rec: MatchRecommendation) -> some View {
        AppButton.primary("查看房源详情", icon: "house.fill") {
            nav.push(.houseDetail(houseId: rec.house.id))
        }
    }

    // MARK: - 工具

    private func kv(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text(label)
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await viewModel.toggleFavorite() }
            } label: {
                Image(systemName: (viewModel.recommendation?.isFavorite ?? false) ? "heart.fill" : "heart")
                    .foregroundStyle((viewModel.recommendation?.isFavorite ?? false) ? AppColor.error : AppColor.textSecondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("匹配详情") {
    NavigationStack {
        MatchDetailView(customerId: "mock-1", houseId: "house-1")
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
