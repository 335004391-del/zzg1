import Foundation

/// 智能匹配引擎 —— 整个匹配流程的统一入口
/// 流程：规则过滤(RuleEngine) → 评分(ScoringEngine) → 推荐组装与排序(RecommendationEngine)
/// 所有匹配算法集中于引擎层，ViewModel / View 严禁实现任何算法
struct MatchEngine {

    private let rule = RuleEngine()
    private let scoring = ScoringEngine()
    private let recommend = RecommendationEngine()

    /// 为客户在全部房源中计算推荐结果
    /// - Parameters:
    ///   - favorites: 已收藏的「customerId-houseId」键集合
    ///   - options: 排序 / 筛选 / Top N
    func match(customer: Customer, houses: [House],
               favorites: Set<String>, options: MatchOptions) -> [MatchRecommendation] {
        // 1) 规则引擎：第一层硬过滤
        let candidates = rule.filter(customer: customer, houses: houses)

        // 2) 评分引擎 + 3) 推荐组装
        let recommendations = candidates.map { house -> MatchRecommendation in
            let score = scoring.score(customer: customer, house: house)
            let key = "\(customer.id)-\(house.id)"
            return recommend.makeRecommendation(
                customer: customer, house: house,
                score: score, isFavorite: favorites.contains(key)
            )
        }

        // 4) 排序 + 筛选 + Top10
        return recommend.rank(recommendations, options: options)
    }

    /// 评估单个客户-房源对（用于详情页，不做过滤/排序）
    func evaluate(customer: Customer, house: House, isFavorite: Bool) -> MatchRecommendation {
        let score = scoring.score(customer: customer, house: house)
        return recommend.makeRecommendation(
            customer: customer, house: house, score: score, isFavorite: isFavorite
        )
    }
}
