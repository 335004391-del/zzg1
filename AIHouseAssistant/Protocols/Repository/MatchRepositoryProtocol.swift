import Foundation

/// 匹配仓储协议 — 定义 AI 智能匹配与推荐操作接口
protocol MatchRepositoryProtocol {

    /// 为客户执行 AI 房源匹配（返回匹配结果列表）
    func match(customerId: String) async throws -> [MatchListItem]

    /// 获取 AI 智能推荐房源
    func recommend(customerId: String, limit: Int) async throws -> [MatchListItem]
}
