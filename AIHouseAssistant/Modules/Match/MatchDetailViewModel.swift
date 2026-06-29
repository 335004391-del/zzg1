import Foundation

/// 匹配详情视图模型 —— 加载单个客户-房源的评估结果
@MainActor
@Observable
final class MatchDetailViewModel {

    private(set) var recommendation: MatchRecommendation?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let customerId: String
    private let houseId: String
    private var repository: (any MatchRepositoryProtocol)?

    init(customerId: String, houseId: String) {
        self.customerId = customerId
        self.houseId = houseId
    }

    func onAppear(repository: any MatchRepositoryProtocol) async {
        self.repository = repository
        if recommendation == nil { await load() }
    }

    private func load() async {
        guard let repository else { return }
        isLoading = true
        errorMessage = nil
        do {
            recommendation = try await repository.recommendation(customerId: customerId, houseId: houseId)
            if recommendation == nil { errorMessage = "未找到匹配数据" }
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    func toggleFavorite() async {
        guard let repository, let current = recommendation else { return }
        do {
            recommendation = try await repository.toggleFavorite(
                customerId: current.customer.id, houseId: current.house.id)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }
}
