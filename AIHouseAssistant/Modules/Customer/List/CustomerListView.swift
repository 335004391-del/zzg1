import SwiftUI

/// 客户列表页 —— 客户管理模块入口
struct CustomerListView: View {

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel = CustomerListViewModel()
    @State private var showFilter = false
    @State private var deleteConfig: ConfirmDialogConfig?

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                controlBar
                content
            }
            .padding(.top, AppSpacing.sm)
        }
        .navigationTitle("客户")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    nav.push(.customerEdit(customerId: nil))
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .task {
            await viewModel.onAppear(repository: container.customerRepository)
        }
        .onChange(of: CustomerEvents.shared.version) {
            Task { await viewModel.reloadAfterExternalChange() }
        }
        .sheet(isPresented: $showFilter) {
            CustomerFilterSheet(initial: viewModel.query.filter) { filter in
                viewModel.applyFilter(filter)
            }
        }
        .confirmDialog(config: $deleteConfig)
    }

    // MARK: - 控制栏（搜索 + 排序 + 筛选 + 收藏）

    private var controlBar: some View {
        VStack(spacing: AppSpacing.sm) {
            SearchBar(placeholder: "搜索姓名 / 电话 / 微信 / 公司", text: searchBinding)
                .onChange(of: viewModel.query.keyword) { _, _ in
                    viewModel.scheduleSearch()
                }

            HStack(spacing: AppSpacing.sm) {
                // 排序
                Menu {
                    Picker("排序", selection: sortBinding) {
                        ForEach(CustomerSortOption.allCases) { option in
                            Label(option.displayName, systemImage: option.icon).tag(option)
                        }
                    }
                } label: {
                    controlChip(icon: "arrow.up.arrow.down",
                                text: viewModel.query.sort.displayName)
                }

                // 筛选
                Button { showFilter = true } label: {
                    controlChip(icon: "line.3.horizontal.decrease.circle",
                                text: "筛选",
                                badge: viewModel.activeFilterCount)
                }
                .buttonStyle(.plain)

                // 仅看收藏
                Button { viewModel.toggleFavoritesOnly() } label: {
                    controlChip(icon: viewModel.query.favoritesOnly ? "star.fill" : "star",
                                text: "收藏",
                                highlighted: viewModel.query.favoritesOnly)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("共 \(viewModel.total)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
            }
        }
        .padding(.horizontal, AppSpacing.base)
    }

    private func controlChip(icon: String, text: String,
                             badge: Int = 0, highlighted: Bool = false) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
            Text(text)
                .font(AppFont.captionMedium)
            if badge > 0 {
                Text("\(badge)")
                    .font(AppFont.caption2)
                    .foregroundStyle(.white)
                    .frame(width: 16, height: 16)
                    .background(AppColor.primary)
                    .clipShape(Circle())
            }
        }
        .foregroundStyle(highlighted ? AppColor.primary : AppColor.textSecondary)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(highlighted ? AppColor.primaryLight : AppColor.card)
        .clipShape(Capsule())
    }

    // MARK: - 内容区

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            AppLoadingView(message: "正在加载客户…")
        } else if let message = viewModel.errorMessage, viewModel.customers.isEmpty {
            ErrorStateView(message: message) {
                Task { await viewModel.reload() }
            }
        } else if viewModel.showEmptyState {
            EmptyStateView(
                icon: "person.3",
                title: "暂无客户",
                message: "没有符合条件的客户\n试试调整搜索或筛选条件",
                actionTitle: "新增客户",
                iconColor: AppColor.primary,
                onAction: { nav.push(.customerEdit(customerId: nil)) }
            )
        } else {
            customerList
        }
    }

    private var customerList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.customers) { customer in
                    CustomerCard(
                        customer: customer,
                        onTap: { nav.push(.customerDetail(customerId: customer.id)) },
                        onToggleFavorite: { Task { await viewModel.toggleFavorite(customer) } }
                    )
                    .contextMenu {
                        cardContextMenu(customer)
                    }
                    .onAppear {
                        // 触底加载更多
                        if customer.id == viewModel.customers.last?.id {
                            Task { await viewModel.loadMore() }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    InlineLoadingView()
                }
            }
            .padding(.horizontal, AppSpacing.base)
            .padding(.bottom, AppSpacing.xl)
        }
        .refreshable { await viewModel.refresh() }
    }

    // MARK: - 卡片长按菜单

    @ViewBuilder
    private func cardContextMenu(_ customer: Customer) -> some View {
        Button {
            nav.push(.customerDetail(customerId: customer.id))
        } label: {
            Label("查看详情", systemImage: "eye")
        }
        Button {
            nav.push(.customerEdit(customerId: customer.id))
        } label: {
            Label("编辑", systemImage: "pencil")
        }
        Button {
            Task { await viewModel.toggleFavorite(customer) }
        } label: {
            Label(customer.isFavorite ? "取消收藏" : "收藏",
                  systemImage: customer.isFavorite ? "star.slash" : "star")
        }
        Divider()
        Button(role: .destructive) {
            requestDelete(customer)
        } label: {
            Label("删除", systemImage: "trash")
        }
    }

    private func requestDelete(_ customer: Customer) {
        deleteConfig = .destructive(
            title: "删除客户",
            message: "确认删除「\(customer.name)」吗？\n删除后该客户所有数据将被清除，此操作不可撤销。",
            onConfirm: {
                Task {
                    await viewModel.delete(customer)
                    ToastManager.shared.success("已删除「\(customer.name)」")
                }
            }
        )
    }

    // MARK: - 绑定

    private var sortBinding: Binding<CustomerSortOption> {
        Binding(
            get: { viewModel.query.sort },
            set: { viewModel.applySort($0) }
        )
    }

    private var searchBinding: Binding<String> {
        Binding(
            get: { viewModel.query.keyword },
            set: { viewModel.query.keyword = $0 }
        )
    }
}

// MARK: - Preview

#Preview("客户列表") {
    NavigationStack {
        CustomerListView()
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
