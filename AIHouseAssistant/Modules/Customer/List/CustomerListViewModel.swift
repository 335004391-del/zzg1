import Foundation

/// 客户列表视图模型 —— 承载搜索 / 筛选 / 排序 / 分页 / 收藏 / 删除全部业务逻辑
@MainActor
@Observable
final class CustomerListViewModel {

    // MARK: - 查询条件

    /// 统一查询条件（搜索 / 筛选 / 排序 / 分页）
    var query = CustomerQuery()

    // MARK: - 数据状态

    private(set) var customers: [Customer] = []
    private(set) var total = 0
    private(set) var hasMore = false
    /// 首屏加载中
    private(set) var isLoading = false
    /// 加载更多中
    private(set) var isLoadingMore = false
    /// 错误信息
    private(set) var errorMessage: String?

    // MARK: - 依赖

    private var repository: (any CustomerRepositoryProtocol)?
    private var hasLoaded = false
    private var searchTask: Task<Void, Never>?

    // MARK: - 计算属性

    /// 已激活筛选数量
    var activeFilterCount: Int { query.filter.activeCount }
    /// 是否展示空状态
    var showEmptyState: Bool { !isLoading && customers.isEmpty && errorMessage == nil }

    // MARK: - 生命周期

    func onAppear(repository: any CustomerRepositoryProtocol) async {
        self.repository = repository
        guard !hasLoaded else { return }
        await reload()
    }

    // MARK: - 搜索（防抖）

    /// 关键词变化时调用 —— 300ms 防抖后重新查询
    func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard let self, !Task.isCancelled else { return }
            await self.reload()
        }
    }

    // MARK: - 筛选 / 排序

    func applyFilter(_ filter: CustomerFilter) {
        query.filter = filter
        Task { await reload() }
    }

    func applySort(_ sort: CustomerSortOption) {
        guard query.sort != sort else { return }
        query.sort = sort
        Task { await reload() }
    }

    func toggleFavoritesOnly() {
        query.favoritesOnly.toggle()
        Task { await reload() }
    }

    // MARK: - 加载

    /// 重新加载第一页
    func reload() async {
        guard let repository else { return }
        query.page = 1
        isLoading = customers.isEmpty
        errorMessage = nil
        do {
            let response = try await repository.query(query)
            customers = response.items
            total     = response.total
            hasMore   = response.hasMore
            hasLoaded = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    /// 外部数据变更后的静默刷新（不闪烁 Loading）
    func reloadAfterExternalChange() async {
        guard hasLoaded, let repository else { return }
        query.page = 1
        do {
            let response = try await repository.query(query)
            customers = response.items
            total     = response.total
            hasMore   = response.hasMore
        } catch {
            // 静默失败，保留当前数据
        }
    }

    /// 加载下一页
    func loadMore() async {
        guard let repository, hasMore, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true
        query.page += 1
        do {
            let response = try await repository.query(query)
            customers.append(contentsOf: response.items)
            hasMore = response.hasMore
        } catch {
            query.page -= 1 // 失败回退页码
        }
        isLoadingMore = false
    }

    /// 下拉刷新
    func refresh() async {
        await reload()
    }

    // MARK: - 收藏 / 删除

    func toggleFavorite(_ customer: Customer) async {
        guard let repository else { return }
        do {
            let updated = try await repository.toggleFavorite(id: customer.id)
            if let index = customers.firstIndex(where: { $0.id == updated.id }) {
                // 若处于"仅看收藏"且已取消收藏，则移出列表
                if query.favoritesOnly && !updated.isFavorite {
                    customers.remove(at: index)
                } else {
                    customers[index] = updated
                }
            }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func delete(_ customer: Customer) async {
        guard let repository else { return }
        do {
            try await repository.delete(id: customer.id)
            customers.removeAll { $0.id == customer.id }
            total = max(0, total - 1)
            CustomerEvents.shared.markChanged()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
