import Foundation

/// 推荐引擎 —— 负责生成推荐理由 / 不推荐原因、排序与 Top10
struct RecommendationEngine {

    // MARK: - 组装单条推荐

    /// 由评分组装一条完整推荐（理由 + 不推荐原因 + 等级）
    func makeRecommendation(customer: Customer, house: House,
                            score: MatchScore, isFavorite: Bool) -> MatchRecommendation {
        MatchRecommendation(
            customer: customer,
            house: house,
            score: score,
            level: level(for: score.final),
            reasons: buildReasons(customer: customer, house: house, score: score),
            mismatchReasons: buildMismatches(customer: customer, house: house, score: score),
            isFavorite: isFavorite
        )
    }

    /// 综合分 → 匹配等级
    private func level(for final: Double) -> MatchLevel {
        switch final {
        case 80...:   return .excellent
        case 60..<80: return .good
        case 40..<60: return .fair
        default:      return .poor
        }
    }

    // MARK: - 推荐理由

    private func buildReasons(customer: Customer, house: House, score: MatchScore) -> [String] {
        var reasons: [String] = []

        if score.budget >= 95 {
            reasons.append("预算完全匹配，总价 \(house.priceDescription)")
        } else if score.budget >= 80 {
            reasons.append("价格在可接受范围内")
        }

        switch score.location {
        case 100: reasons.append("正好位于意向区域 \(house.district)")
        case 70:  reasons.append("邻近意向区域，通勤可接受")
        default:  break
        }

        if score.area >= 90 { reasons.append("面积 \(house.areaDescription) 符合需求") }
        if score.layout >= 100 { reasons.append("户型完全匹配（\(house.layoutDescription)）") }

        if score.school >= 100, customer.schoolRequirement || customer.tags.contains(.school) {
            reasons.append("学区优质，满足子女教育需求")
        }
        if score.subway >= 80, let distance = house.subwayDistance {
            reasons.append("距地铁约 \(distance) 米，出行便利")
        }

        // 标签卖点
        let matchedTags = matchedTagNames(customer: customer, house: house)
        if !matchedTags.isEmpty {
            reasons.append("包含\(matchedTags.joined(separator: "、"))等卖点")
        }
        if house.orientation == .south || house.orientation == .southEast {
            reasons.append("南向采光好，南北通透")
        }

        return reasons.isEmpty ? ["综合条件较为均衡"] : reasons
    }

    // MARK: - 不推荐原因

    private func buildMismatches(customer: Customer, house: House, score: MatchScore) -> [String] {
        var list: [String] = []

        if house.price > customer.budgetMax, customer.budgetMax > 0 {
            let over = Int(house.price - customer.budgetMax)
            list.append("预算高出约 \(over) 万")
        }
        if score.location <= 40 {
            list.append("距离意向区域较远")
        }
        if score.area < 70 {
            list.append("面积与需求差距较大")
        }
        if score.layout < 70 {
            list.append("户型不符（房源 \(house.rooms) 室 / 期望 \(customer.roomsDescription)）")
        }
        if score.school <= 30, customer.schoolRequirement || customer.tags.contains(.school) {
            list.append("非学区房，不满足教育需求")
        }
        if score.subway <= 40, customer.subwayRequirement || customer.tags.contains(.subway) {
            list.append("距地铁较远，通勤不便")
        }
        return list
    }

    /// 命中的标签名称
    private func matchedTagNames(customer: Customer, house: House) -> [String] {
        let houseTags = Set(house.tags)
        return customer.tags.compactMap { customerTag -> String? in
            guard let mapped = ScoringEngine.tagMapping[customerTag],
                  houseTags.contains(mapped) else { return nil }
            return mapped.displayName
        }
    }

    // MARK: - 排序 + 筛选 + Top10

    /// 应用筛选、排序、TopN
    func rank(_ recommendations: [MatchRecommendation], options: MatchOptions) -> [MatchRecommendation] {
        var result = recommendations

        // 筛选
        result = result.filter { rec in
            if rec.scoreInt < options.minScore { return false }
            if options.schoolOnly, !(rec.house.schoolInfo != nil || rec.house.tags.contains(.school)) { return false }
            if options.subwayOnly, !rec.house.hasSubway { return false }
            if options.favoritesOnly, !rec.isFavorite { return false }
            return true
        }

        // 排序
        result = sorted(result, by: options.sort)

        // Top N
        if options.topN > 0 {
            result = Array(result.prefix(options.topN))
        }
        return result
    }

    private func sorted(_ list: [MatchRecommendation], by sort: MatchSortOption) -> [MatchRecommendation] {
        switch sort {
        case .overall:
            return list.sorted { $0.score.final > $1.score.final }
        case .budget:
            return list.sorted { $0.score.budget > $1.score.budget }
        case .distance:
            return list.sorted {
                ($0.house.subwayDistance ?? Int.max) < ($1.house.subwayDistance ?? Int.max)
            }
        case .area:
            return list.sorted { $0.house.area > $1.house.area }
        case .newest:
            return list.sorted { $0.house.createdAt > $1.house.createdAt }
        case .lowestPrice:
            return list.sorted { $0.house.price < $1.house.price }
        }
    }
}
