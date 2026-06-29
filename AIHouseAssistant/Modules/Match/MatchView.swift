import SwiftUI

/// 智能匹配页 —— 选择客户 → 开始匹配 → Top10 推荐
struct MatchView: View {

    let preselectedCustomerId: String?

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel = MatchViewModel()
    @State private var showPicker = false

    init(preselectedCustomerId: String? = nil) {
        self.preselectedCustomerId = preselectedCustomerId
    }

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                customerSelector
                if viewModel.hasMatched {
                    controlBar
                }
                content
            }
            .padding(.top, AppSpacing.sm)
        }
        .navigationTitle("智能匹配")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.onAppear(repository: container.matchRepository,
                                     preselectedCustomerId: preselectedCustomerId)
        }
        .sheet(isPresented: $showPicker) {
            CustomerPickerSheet(customers: viewModel.customers) { customer in
                viewModel.selectCustomer(customer)
            }
        }
    }

    // MARK: - 客户选择器

    private var customerSelector: some View {
        Button { showPicker = true } label: {
            CardView {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle().fill(AppColor.primaryLight).frame(width: 44, height: 44)
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 18))
                            .foregroundStyle(AppColor.primary)
                    }
                    if let customer = viewModel.selectedCustomer {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(customer.name)
                                .font(AppFont.bodyMedium)
                                .foregroundStyle(AppColor.textPrimary)
                            Text("\(customer.budgetDescription) · \(customer.primaryArea) · \(customer.roomsDescription)")
                                .font(AppFont.caption)
                                .foregroundStyle(AppColor.textSecondary)
                                .lineLimit(1)
                        }
                    } else {
                        Text("请选择要匹配的客户")
                            .font(AppFont.bodyMedium)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    Spacer()
                    Text(viewModel.selectedCustomer == nil ? "选择" : "更换")
                        .font(AppFont.captionMedium)
                        .foregroundStyle(AppColor.primary)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.base)
    }

    // MARK: - 内容

    @ViewBuilder
    private var content: some View {
        if viewModel.isMatching {
            matchingView
        } else if let message = viewModel.errorMessage, viewModel.recommendations.isEmpty {
            ErrorStateView(message: message) {
                Task { await viewModel.startMatch() }
            }
        } else if !viewModel.hasMatched {
            startMatchPrompt
        } else if viewModel.recommendations.isEmpty {
            EmptyStateView(
                icon: "sparkle.magnifyingglass",
                title: "暂无匹配房源",
                message: "当前筛选条件下没有合适房源\n试试降低分数门槛或调整筛选",
                iconColor: AppColor.primary
            )
        } else {
            recommendationList
        }
    }

    // MARK: - 开始匹配引导

    private var startMatchPrompt: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(AppColor.aiPurple.opacity(0.1)).frame(width: 96, height: 96)
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColor.aiGradient)
            }
            VStack(spacing: AppSpacing.sm) {
                Text("AI 智能匹配引擎")
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.textPrimary)
                Text(viewModel.selectedCustomer == nil
                     ? "请先选择客户，引擎将从全部房源中为其匹配 Top10"
                     : "点击下方按钮，开始为「\(viewModel.selectedCustomer!.name)」匹配房源")
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppSpacing.xxxl)

            AppButton.primary("开始匹配", icon: "sparkles",
                              isFullWidth: false,
                              isDisabled: viewModel.selectedCustomer == nil) {
                Task { await viewModel.startMatch() }
            }
            Spacer()
        }
    }

    // MARK: - 匹配中

    private var matchingView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            ProgressView().scaleEffect(1.4).tint(AppColor.primary)
            Text("规则引擎正在计算匹配度…")
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
        }
    }

    // MARK: - 推荐列表

    private var recommendationList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                HStack {
                    Text("为「\(viewModel.selectedCustomer?.name ?? "")」推荐 Top\(viewModel.recommendations.count)")
                        .font(AppFont.labelMedium)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                }
                ForEach(viewModel.recommendations) { rec in
                    MatchRecommendationCard(
                        recommendation: rec,
                        onTapDetail: {
                            nav.push(.matchDetail(customerId: rec.customer.id, houseId: rec.house.id))
                        },
                        onToggleFavorite: { Task { await viewModel.toggleFavorite(rec) } }
                    )
                }
            }
            .padding(.horizontal, AppSpacing.base)
            .padding(.bottom, AppSpacing.xl)
        }
    }

    // MARK: - 排序 / 筛选控制栏

    private var controlBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                Menu {
                    Picker("排序", selection: sortBinding) {
                        ForEach(MatchSortOption.allCases) { option in
                            Label(option.displayName, systemImage: option.icon).tag(option)
                        }
                    }
                } label: {
                    chip(icon: "arrow.up.arrow.down", text: viewModel.options.sort.displayName)
                }

                Menu {
                    Picker("分数", selection: thresholdBinding) {
                        ForEach(MatchScoreThreshold.allCases) { t in
                            Text(t.displayName).tag(t)
                        }
                    }
                } label: {
                    chip(icon: "chart.bar", text: thresholdLabel)
                }

                toggleChip(icon: "graduationcap", text: "学区",
                           on: viewModel.options.schoolOnly) { viewModel.toggleSchoolOnly() }
                toggleChip(icon: "tram.fill", text: "地铁",
                           on: viewModel.options.subwayOnly) { viewModel.toggleSubwayOnly() }
                toggleChip(icon: "heart", text: "收藏",
                           on: viewModel.options.favoritesOnly) { viewModel.toggleFavoritesOnly() }
            }
            .padding(.horizontal, AppSpacing.base)
        }
    }

    private func chip(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon).font(.system(size: 12, weight: .medium))
            Text(text).font(AppFont.captionMedium)
        }
        .foregroundStyle(AppColor.textSecondary)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColor.card)
        .clipShape(Capsule())
    }

    private func toggleChip(icon: String, text: String, on: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon).font(.system(size: 12, weight: .medium))
                Text(text).font(AppFont.captionMedium)
            }
            .foregroundStyle(on ? .white : AppColor.textSecondary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(on ? AppColor.primary : AppColor.card)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var thresholdLabel: String {
        MatchScoreThreshold(rawValue: viewModel.options.minScore)?.displayName ?? "全部"
    }

    private var sortBinding: Binding<MatchSortOption> {
        Binding(get: { viewModel.options.sort }, set: { viewModel.applySort($0) })
    }

    private var thresholdBinding: Binding<MatchScoreThreshold> {
        Binding(
            get: { MatchScoreThreshold(rawValue: viewModel.options.minScore) ?? .all },
            set: { viewModel.applyThreshold($0) }
        )
    }
}

// MARK: - Preview

#Preview("智能匹配") {
    NavigationStack {
        MatchView()
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
