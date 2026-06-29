import Foundation

/// 匹配仓储协议 —— 客户读取 + 智能匹配 + 单项评估 + 收藏
protocol MatchRepositoryProtocol {

    /// 可用于匹配的客户列表（供客户选择器）
    func customers() async throws -> [Customer]

    /// 为指定客户计算推荐（经由 MatchEngine，按选项排序/筛选/Top10）
    func recommend(customerId: String, options: MatchOptions) async throws -> [MatchRecommendation]

    /// 评估单个客户-房源对（详情页用）
    func recommendation(customerId: String, houseId: String) async throws -> MatchRecommendation?

    /// 切换推荐收藏状态，返回更新后的推荐
    func toggleFavorite(customerId: String, houseId: String) async throws -> MatchRecommendation
}
