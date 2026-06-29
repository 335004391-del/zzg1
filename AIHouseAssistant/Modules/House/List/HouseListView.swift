import SwiftUI

/// 房源列表页 —— 房源管理模块入口
struct HouseListView: View {

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel = HouseListViewModel()
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
        .navigationTitle("房源")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    nav.push(.houseEdit(houseId: nil))
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .task {
            await viewModel.onAppear(repository: container.houseRepository)
        }
        .onChange(of: HouseEvents.shared.version) {
            Task { await viewModel.reloadAfterExternalChange() }
        }
        .sheet(isPresented: $showFilter) {
            HouseFilterSheet(initial: viewModel.query.filter) { filter in
                viewModel.applyFilter(filter)
            }
        }
        .confirmDialog(config: $deleteConfig)
    }

    // MARK: - 控制栏

    private var controlBar: some View {
        VStack(spacing: AppSpacing.sm) {
            SearchBar(placeholder: "搜索小区 / 标题 / 地址 / 编号", text: searchBinding)
                .onChange(of: viewModel.query.keyword) { _, _ in
                    viewModel.scheduleSearch()
                }

            HStack(spacing: AppSpacing.sm) {
                Menu {
                    Picker("排序", selection: sortBinding) {
                        ForEach(HouseSortOption.allCases) { option in
                            Label(option.displayName, systemImage: option.icon).tag(option)
                        }
                    }
                } label: {
                    controlChip(icon: "arrow.up.arrow.down", text: viewModel.query.sort.displayName)
                }

                Button { showFilter = true } label: {
                    controlChip(icon: "slider.horizontal.3", text: "筛选",
                                badge: viewModel.activeFilterCount)
                }
                .buttonStyle(.plain)

                Button { viewModel.toggleFavoritesOnly() } label: {
                    controlChip(icon: viewModel.query.favoritesOnly ? "heart.fill" : "heart",
                                text: "收藏", highlighted: viewModel.query.favoritesOnly)
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
            Image(systemName: icon).font(.system(size: 12, weight: .medium))
            Text(text).font(AppFont.captionMedium)
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

    // MARK: - 内容

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            AppLoadingView(message: "正在加载房源…")
        } else if let message = viewModel.errorMessage, viewModel.houses.isEmpty {
            ErrorStateView(message: message) {
                Task { await viewModel.reload() }
            }
        } else if viewModel.showEmptyState {
            EmptyStateView(
                icon: "building.2",
                title: "暂无房源",
                message: "没有符合条件的房源\n试试调整搜索或筛选条件",
                actionTitle: "新增房源",
                iconColor: AppColor.primary,
                onAction: { nav.push(.houseEdit(houseId: nil)) }
            )
        } else {
            houseList
        }
    }

    private var houseList: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.md) {
                ForEach(viewModel.houses) { house in
                    HouseCard(
                        house: house,
                        onTap: { nav.push(.houseDetail(houseId: house.id)) },
                        onToggleFavorite: { Task { await viewModel.toggleFavorite(house) } }
                    )
                    .contextMenu { cardContextMenu(house) }
                    .onAppear {
                        if house.id == viewModel.houses.last?.id {
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

    // MARK: - 长按菜单

    @ViewBuilder
    private func cardContextMenu(_ house: House) -> some View {
        Button {
            nav.push(.houseDetail(houseId: house.id))
        } label: { Label("查看详情", systemImage: "eye") }
        Button {
            nav.push(.houseEdit(houseId: house.id))
        } label: { Label("编辑", systemImage: "pencil") }
        Button {
            Task { await viewModel.toggleFavorite(house) }
        } label: {
            Label(house.isFavorite ? "取消收藏" : "收藏",
                  systemImage: house.isFavorite ? "heart.slash" : "heart")
        }
        Divider()
        Button(role: .destructive) {
            requestDelete(house)
        } label: { Label("删除", systemImage: "trash") }
    }

    private func requestDelete(_ house: House) {
        deleteConfig = .destructive(
            title: "删除房源",
            message: "确认删除「\(house.community)」吗？\n此操作不可撤销。",
            onConfirm: {
                Task {
                    await viewModel.delete(house)
                    ToastManager.shared.success("已删除「\(house.community)」")
                }
            }
        )
    }

    // MARK: - 绑定

    private var sortBinding: Binding<HouseSortOption> {
        Binding(get: { viewModel.query.sort }, set: { viewModel.applySort($0) })
    }

    private var searchBinding: Binding<String> {
        Binding(get: { viewModel.query.keyword }, set: { viewModel.query.keyword = $0 })
    }
}

// MARK: - Preview

#Preview("房源列表") {
    NavigationStack {
        HouseListView()
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
