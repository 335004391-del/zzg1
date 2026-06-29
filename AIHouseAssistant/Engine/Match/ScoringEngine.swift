import Foundation

/// 评分引擎 —— 计算客户与房源在各维度的匹配分及加权综合分
/// 所有评分算法集中于此，禁止在 View / ViewModel 中实现
struct ScoringEngine {

    /// 计算一组客户-房源的完整评分
    func score(customer: Customer, house: House) -> MatchScore {
        let budget   = budgetScore(customer: customer, house: house)
        let location = locationScore(customer: customer, house: house)
        let area     = areaScore(customer: customer, house: house)
        let layout   = layoutScore(customer: customer, house: house)
        let tag      = tagScore(customer: customer, house: house)
        let school   = schoolScore(customer: customer, house: house)
        let subway   = subwayScore(customer: customer, house: house)

        // 加权综合分
        let final =
            budget   * ScoreDimension.budget.weight +
            location * ScoreDimension.location.weight +
            area     * ScoreDimension.area.weight +
            layout   * ScoreDimension.layout.weight +
            tag      * ScoreDimension.tag.weight +
            school   * ScoreDimension.school.weight +
            subway   * ScoreDimension.subway.weight

        return MatchScore(
            budget: budget, location: location, area: area, layout: layout,
            tag: tag, school: school, subway: subway,
            final: (final * 10).rounded() / 10   // 保留 1 位小数
        )
    }

    // MARK: - 预算（30%）

    /// 区间内 100；低于下限 85；超预算按比例衰减
    private func budgetScore(customer: Customer, house: House) -> Double {
        let minB = customer.budgetMin
        let maxB = customer.budgetMax
        guard maxB > 0 else { return 80 }

        if house.price >= minB && house.price <= maxB { return 100 }
        if house.price < minB {
            // 低于预算，仍可接受（可能品质偏低）
            return 85
        }
        // 超预算：每超 1% 扣约 2.5 分
        let overRatio = (house.price - maxB) / maxB
        return clamp(100 - overRatio * 250)
    }

    // MARK: - 区域（25%）

    /// 完全一致 100；相邻区域 70；同城 40；无偏好 70
    private func locationScore(customer: Customer, house: House) -> Double {
        let preferred = customer.preferredArea
        guard !preferred.isEmpty else { return 70 }

        if preferred.contains(house.district) { return 100 }
        // 相邻区域
        let adjacent = preferred.flatMap { Self.adjacency[$0] ?? [] }
        if adjacent.contains(house.district) { return 70 }
        // 同城市（默认同城）
        return 40
    }

    /// 区域相邻关系表（上海主要城区）
    static let adjacency: [String: [String]] = [
        "浦东新区": ["黄浦区", "杨浦区", "徐汇区"],
        "静安区":   ["黄浦区", "普陀区", "长宁区", "虹口区"],
        "黄浦区":   ["静安区", "浦东新区", "徐汇区", "虹口区"],
        "徐汇区":   ["黄浦区", "长宁区", "闵行区", "浦东新区"],
        "长宁区":   ["静安区", "徐汇区", "普陀区"],
        "闵行区":   ["徐汇区", "松江区", "闵行区"],
        "杨浦区":   ["虹口区", "浦东新区", "宝山区"],
        "普陀区":   ["静安区", "长宁区", "宝山区"],
        "虹口区":   ["黄浦区", "杨浦区", "静安区"],
        "宝山区":   ["杨浦区", "普陀区"],
        "松江区":   ["闵行区", "青浦区"],
        "青浦区":   ["松江区", "闵行区"],
    ]

    // MARK: - 面积（15%）

    /// 区间内 100；±5㎡ 100；±10㎡ 90；±20㎡ 70；更远线性衰减
    private func areaScore(customer: Customer, house: House) -> Double {
        let minA = customer.expectedAreaMin
        let maxA = customer.expectedAreaMax
        guard minA != nil || maxA != nil else { return 80 }

        let lower = minA ?? 0
        let upper = maxA ?? Double.greatestFiniteMagnitude
        if house.area >= lower && house.area <= upper { return 100 }

        // 与最近边界的差距
        let diff: Double
        if house.area < lower { diff = lower - house.area }
        else { diff = house.area - upper }

        switch diff {
        case ..<5:   return 100
        case ..<10:  return 90
        case ..<20:  return 70
        default:     return clamp(70 - (diff - 20) * 2)
        }
    }

    // MARK: - 户型（10%）

    /// 完全一致 100；多一房 85；少一房 70；其他线性衰减
    private func layoutScore(customer: Customer, house: House) -> Double {
        let expected = customer.expectedRooms
        guard !expected.isEmpty else { return 80 }
        if expected.contains(house.rooms) { return 100 }

        // 与最接近期望房数的差
        let nearest = expected.min(by: { abs($0 - house.rooms) < abs($1 - house.rooms) })!
        let diff = house.rooms - nearest
        switch diff {
        case 1:   return 85   // 多一房
        case -1:  return 70   // 少一房
        default:  return clamp(100 - Double(abs(diff)) * 25)
        }
    }

    // MARK: - 标签（10%）

    /// 客户标签与房源标签语义重合度
    private func tagScore(customer: Customer, house: House) -> Double {
        guard !customer.tags.isEmpty else { return 80 }
        let houseTags = Set(house.tags)
        let matched = customer.tags.filter { customerTag in
            if let mapped = Self.tagMapping[customerTag] {
                return houseTags.contains(mapped)
            }
            return false
        }.count
        let ratio = Double(matched) / Double(customer.tags.count)
        return clamp(60 + ratio * 40)
    }

    /// 客户标签 → 房源标签 语义映射
    static let tagMapping: [CustomerTag: HouseTag] = [
        .school:     .school,
        .subway:     .subway,
        .river:      .scenery,
        .lake:       .scenery,
        .luxury:     .villa,
        .upgrade:    .nearNew,
    ]

    // MARK: - 学区（5%）

    /// 需要学区时：有学区 100 / 无 30；不需要时 100
    private func schoolScore(customer: Customer, house: House) -> Double {
        let needs = customer.schoolRequirement || customer.tags.contains(.school)
        guard needs else { return 100 }
        let hasSchool = house.schoolInfo != nil || house.tags.contains(.school)
        return hasSchool ? 100 : 30
    }

    // MARK: - 地铁（5%）

    /// 需要地铁时：按距离评分；不需要时 100
    private func subwayScore(customer: Customer, house: House) -> Double {
        let needs = customer.subwayRequirement || customer.tags.contains(.subway)
        guard needs else { return 100 }
        guard let distance = house.subwayDistance else { return 20 }
        switch distance {
        case ..<500:   return 100
        case ..<1000:  return 80
        case ..<1500:  return 60
        default:       return 40
        }
    }

    // MARK: - 工具

    private func clamp(_ value: Double) -> Double {
        min(100, max(0, value))
    }
}
