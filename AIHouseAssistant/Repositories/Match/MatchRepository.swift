import Foundation

/// 匹配仓储 — 通过 APIClient 执行 AI 智能匹配与推荐请求
final class MatchRepository: MatchRepositoryProtocol, BaseRepository {

    // MARK: - 依赖

    let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - AI 匹配

    func match(customerId: String) async throws -> [MatchListItem] {
        try await fetch(AppEndpoint.AI.match(customerId: customerId))
    }

    func recommend(customerId: String, limit: Int) async throws -> [MatchListItem] {
        try await fetch(AppEndpoint.AI.recommend(customerId: customerId, limit: limit))
    }
}
