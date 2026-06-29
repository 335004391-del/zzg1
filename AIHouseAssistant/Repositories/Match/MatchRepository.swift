import Foundation

/// 真实匹配仓储 —— 预留后端实现（当前未接入服务器）
/// Release 环境注入；DEBUG 环境使用 MockMatchRepository（本地 MatchEngine 计算）
final class MatchRepository: MatchRepositoryProtocol, BaseRepository {

    let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func customers() async throws -> [Customer] {
        // TODO: 接入后端客户列表
        let page = PageRequest(page: 1, pageSize: 100)
        let response: PageResponse<Customer> = try await fetch(AppEndpoint.Customer.list(page))
        return response.items
    }

    func recommend(customerId: String, options: MatchOptions) async throws -> [MatchRecommendation] {
        // TODO: 接入后端 AI 匹配接口
        throw APIError.businessError(code: -1, message: "AI 匹配服务尚未接入")
    }

    func recommendation(customerId: String, houseId: String) async throws -> MatchRecommendation? {
        throw APIError.businessError(code: -1, message: "AI 匹配服务尚未接入")
    }

    func toggleFavorite(customerId: String, houseId: String) async throws -> MatchRecommendation {
        throw APIError.businessError(code: -1, message: "AI 匹配服务尚未接入")
    }
}
