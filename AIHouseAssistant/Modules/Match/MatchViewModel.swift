import Foundation

/// 匹配视图模型 —— 仅负责状态与调度，所有算法在 MatchEngine（经由 Repository）
@MainActor
@Observable
final class MatchViewModel {

    // MARK: - 状态

    private(set) var customers: [Customer] = []
    private(set) var selectedCustomer: Customer?
    private(set) var recommendations: [MatchRecommendation] = []

    /// 匹配选项（排序 / 筛选 / Top10）
    var options = MatchOptions()

    private(set) var isLoadingCustomers = false
    private(set) var isMatching = false
    private(set) var hasMatched = false
    private(set) var errorMessage: String?

    private var repository: (any MatchRepositoryProtocol)?
    private var preselectedCustomerId: String?

    // MARK: - 生命周期

    func onAppear(repository: any MatchRepositoryProtocol, preselectedCustomerId: String?) async {
        self.repository = repository
        self.preselectedCustomerId = preselectedCustomerId
        if customers.isEmpty { await loadCustomers() }
    }

    private func loadCustomers() async {
        guard let repository else { return }
        isLoadingCustomers = true
        errorMessage = nil
        do {
            customers = try await repository.customers()
            // 预选客户（来自房源/客户详情跳转）
            if let id = preselectedCustomerId,
               let customer = customers.first(where: { $0.id == id }) {
                selectedCustomer = customer
                await startMatch()
            }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoadingCustomers = false
    }

    // MARK: - 选择客户

    func selectCustomer(_ customer: Customer) {
        selectedCustomer = customer
        recommendations = []
        hasMatched = false
    }

    // MARK: - 开始匹配

    func startMatch() async {
        guard let repository, let customer = selectedCustomer else { return }
        isMatching = true
        errorMessage = nil
        do {
            recommendations = try await repository.recommend(customerId: customer.id, options: options)
            hasMatched = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isMatching = false
    }

    // MARK: - 排序 / 筛选（变更后自动重算）

    func applySort(_ sort: MatchSortOption) {
        guard options.sort != sort else { return }
        options.sort = sort
        Task { await startMatch() }
    }

    func applyThreshold(_ threshold: MatchScoreThreshold) {
        options.minScore = threshold.rawValue
        Task { await startMatch() }
    }

    func toggleSchoolOnly() {
        options.schoolOnly.toggle()
        Task { await startMatch() }
    }

    func toggleSubwayOnly() {
        options.subwayOnly.toggle()
        Task { await startMatch() }
    }

    func toggleFavoritesOnly() {
        options.favoritesOnly.toggle()
        Task { await startMatch() }
    }

    // MARK: - 收藏

    func toggleFavorite(_ recommendation: MatchRecommendation) async {
        guard let repository else { return }
        do {
            let updated = try await repository.toggleFavorite(
                customerId: recommendation.customer.id,
                houseId: recommendation.house.id
            )
            if let index = recommendations.firstIndex(where: { $0.id == updated.id }) {
                if options.favoritesOnly && !updated.isFavorite {
                    recommendations.remove(at: index)
                } else {
                    recommendations[index] = updated
                }
            }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
