import Foundation

/// 房源列表视图模型 —— 搜索 / 高级筛选 / 排序 / 分页 / 收藏 / 删除
@MainActor
@Observable
final class HouseListViewModel {

    // MARK: - 查询条件

    var query = HouseQuery()

    // MARK: - 数据状态

    private(set) var houses: [House] = []
    private(set) var total = 0
    private(set) var hasMore = false
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var errorMessage: String?

    // MARK: - 依赖

    private var repository: (any HouseRepositoryProtocol)?
    private var hasLoaded = false
    private var searchTask: Task<Void, Never>?

    // MARK: - 计算属性

    var activeFilterCount: Int { query.filter.activeCount }
    var showEmptyState: Bool { !isLoading && houses.isEmpty && errorMessage == nil }

    // MARK: - 生命周期

    func onAppear(repository: any HouseRepositoryProtocol) async {
        self.repository = repository
        guard !hasLoaded else { return }
        await reload()
    }

    // MARK: - 搜索防抖

    func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard let self, !Task.isCancelled else { return }
            await self.reload()
        }
    }

    // MARK: - 筛选 / 排序

    func applyFilter(_ filter: HouseFilter) {
        query.filter = filter
        Task { await reload() }
    }

    func applySort(_ sort: HouseSortOption) {
        guard query.sort != sort else { return }
        query.sort = sort
        Task { await reload() }
    }

    func toggleFavoritesOnly() {
        query.favoritesOnly.toggle()
        Task { await reload() }
    }

    // MARK: - 加载

    func reload() async {
        guard let repository else { return }
        query.page = 1
        isLoading = houses.isEmpty
        errorMessage = nil
        do {
            let response = try await repository.query(query)
            houses    = response.items
            total     = response.total
            hasMore   = response.hasMore
            hasLoaded = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    func reloadAfterExternalChange() async {
        guard hasLoaded, let repository else { return }
        query.page = 1
        do {
            let response = try await repository.query(query)
            houses  = response.items
            total   = response.total
            hasMore = response.hasMore
        } catch {
            // 静默失败
        }
    }

    func loadMore() async {
        guard let repository, hasMore, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true
        query.page += 1
        do {
            let response = try await repository.query(query)
            houses.append(contentsOf: response.items)
            hasMore = response.hasMore
        } catch {
            query.page -= 1
        }
        isLoadingMore = false
    }

    func refresh() async {
        await reload()
    }

    // MARK: - 收藏 / 删除

    func toggleFavorite(_ house: House) async {
        guard let repository else { return }
        do {
            let updated = try await repository.toggleFavorite(id: house.id)
            if let index = houses.firstIndex(where: { $0.id == updated.id }) {
                if query.favoritesOnly && !updated.isFavorite {
                    houses.remove(at: index)
                } else {
                    houses[index] = updated
                }
            }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func delete(_ house: House) async {
        guard let repository else { return }
        do {
            try await repository.delete(id: house.id)
            houses.removeAll { $0.id == house.id }
            total = max(0, total - 1)
            HouseEvents.shared.markChanged()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
