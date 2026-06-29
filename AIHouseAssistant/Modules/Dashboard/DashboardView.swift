import SwiftUI

/// 首页（Dashboard）—— 用户登录后的第一个页面
/// 仅负责「组装 + 转发交互」，所有业务逻辑位于 DashboardViewModel
struct DashboardView: View {

    // MARK: - 依赖

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    /// 视图模型
    @State private var viewModel = DashboardViewModel()
    /// 入场动画开关
    @State private var isAppeared = false

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            content
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            // 首次进入加载（数据来自 Mock Repository）
            await viewModel.onAppear(repository: container.dashboardRepository)
            withAnimation(AppAnimation.slow) { isAppeared = true }
        }
    }

    // MARK: - 内容分发（加载 / 错误 / 正常）

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.overview == nil {
            AppLoadingView(message: "正在加载首页…")
        } else if let message = viewModel.errorMessage, viewModel.overview == nil {
            ErrorStateView(message: message) {
                Task { await viewModel.refresh() }
            }
        } else if let overview = viewModel.overview {
            dashboardScroll(overview)
        }
    }

    // MARK: - 首页滚动主体

    private func dashboardScroll(_ overview: DashboardOverview) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {

                // 顶部导航
                DashboardHeaderView(
                    time: viewModel.currentTime,
                    greeting: viewModel.greetingTitle,
                    onTapNotification: { ToastManager.shared.info("暂无新通知") },
                    onTapAvatar: { nav.selectTab(.profile) }
                )
                .padding(.horizontal, AppSpacing.base)

                // 欢迎区域
                DashboardWelcomeCard(todayText: viewModel.todayText)
                    .padding(.horizontal, AppSpacing.base)

                // 今日统计（横向滚动）
                DashboardStatsRow(stats: overview.stats)

                // AI 今日建议
                DashboardAISuggestionCard(
                    suggestion: overview.aiSuggestion,
                    onContact: {
                        nav.push(.customerDetail(customerId: overview.aiSuggestion.customerId))
                    },
                    onRemindLater: { ToastManager.shared.success("已设置稍后提醒") }
                )
                .padding(.horizontal, AppSpacing.base)

                // 待跟进客户
                DashboardFollowUpSection(
                    followUps: overview.followUps,
                    onTapCustomer: { id in nav.push(.customerDetail(customerId: id)) },
                    onViewAll: { nav.selectTab(.customer) }
                )
                .padding(.horizontal, AppSpacing.base)

                // 最新房源（全幅横向滚动）
                DashboardHousesSection(
                    houses: overview.latestHouses,
                    onTapHouse: { id in nav.push(.houseDetail(houseId: id)) },
                    onViewAll: { nav.selectTab(.house) }
                )

                // AI 推荐
                DashboardRecommendationSection(
                    recommendations: overview.recommendations,
                    onViewReason: { item in nav.push(.aiReport(matchId: item.id)) }
                )

                // 快捷功能
                DashboardQuickActionsGrid(onTap: handleQuickAction)

                // 底部留白（避开 TabBar）
                Spacer().frame(height: AppSpacing.xl)
            }
            .padding(.top, AppSpacing.base)
            .opacity(isAppeared ? 1 : 0)
            .offset(y: isAppeared ? 0 : 12)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - 快捷功能路由

    private func handleQuickAction(_ action: DashboardQuickAction) {
        switch action {
        case .customer:    nav.selectTab(.customer)
        case .house:       nav.selectTab(.house)
        case .match:       nav.selectTab(.ai)
        case .settings:    nav.push(.settings)
        case .excelImport: nav.push(.importHome)
        // 以下功能页面尚未开发，先以 Toast 占位
        case .todo:        ToastManager.shared.info("今日待办：敬请期待")
        case .ranking:     ToastManager.shared.info("销售排行：敬请期待")
        case .bossView:    ToastManager.shared.info("老板驾驶舱：敬请期待")
        }
    }
}

// MARK: - Preview

#Preview("首页 - 浅色") {
    DashboardView()
        .environmentObject(DependencyContainer.shared)
        .environment(NavigationManager.shared)
}

#Preview("首页 - 深色") {
    DashboardView()
        .environmentObject(DependencyContainer.shared)
        .environment(NavigationManager.shared)
        .preferredColorScheme(.dark)
}
