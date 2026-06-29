import Foundation

/// 评分维度 —— 含权重定义（第一版规则引擎权重，总和 100%）
enum ScoreDimension: String, CaseIterable, Identifiable {
    case budget    // 预算 30%
    case location  // 区域 25%
    case area      // 面积 15%
    case layout    // 户型 10%
    case tag       // 标签 10%
    case school    // 学区 5%
    case subway    // 地铁 5%

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .budget:   return "预算"
        case .location: return "区域"
        case .area:     return "面积"
        case .layout:   return "户型"
        case .tag:      return "标签"
        case .school:   return "学区"
        case .subway:   return "地铁"
        }
    }

    /// 权重（0~1）
    var weight: Double {
        switch self {
        case .budget:   return 0.30
        case .location: return 0.25
        case .area:     return 0.15
        case .layout:   return 0.10
        case .tag:      return 0.10
        case .school:   return 0.05
        case .subway:   return 0.05
        }
    }
}

// MARK: - 匹配评分

/// 单次匹配的完整评分（各维度 0~100 + 加权综合分）
struct MatchScore: Hashable {
    var budget:   Double
    var location: Double
    var area:     Double
    var layout:   Double
    var tag:      Double
    var school:   Double
    var subway:   Double
    /// 加权综合分（0~100）
    var final:    Double

    /// 取某维度分值
    func value(for dimension: ScoreDimension) -> Double {
        switch dimension {
        case .budget:   return budget
        case .location: return location
        case .area:     return area
        case .layout:   return layout
        case .tag:      return tag
        case .school:   return school
        case .subway:   return subway
        }
    }

    /// 各维度明细（用于评分详情 / 雷达图）
    var breakdown: [(dimension: ScoreDimension, value: Double)] {
        ScoreDimension.allCases.map { ($0, value(for: $0)) }
    }
}

// MARK: - 匹配推荐结果

/// 一条匹配推荐（客户 × 房源）
struct MatchRecommendation: Identifiable, Hashable {
    let customer: Customer
    let house: House
    let score: MatchScore
    let level: MatchLevel
    /// 推荐理由
    let reasons: [String]
    /// 不推荐原因
    let mismatchReasons: [String]
    /// 是否收藏
    var isFavorite: Bool

    var id: String { "\(customer.id)-\(house.id)" }

    /// 综合分整数展示
    var scoreInt: Int { Int(score.final.rounded()) }
}

// MARK: - 匹配选项（排序 + 筛选 + TopN）

struct MatchOptions: Equatable {
    var sort: MatchSortOption = .overall
    /// 最低分阈值（0 / 80 / 90 / 95）
    var minScore: Int = 0
    var schoolOnly: Bool = false
    var subwayOnly: Bool = false
    var favoritesOnly: Bool = false
    /// 取前 N 条（Top10）
    var topN: Int = 10
}

/// 排序方式
enum MatchSortOption: String, CaseIterable, Identifiable {
    case overall      // 综合评分
    case budget       // 预算优先
    case distance     // 距离优先
    case area         // 面积优先
    case newest       // 最新房源
    case lowestPrice  // 价格最低

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .overall:     return "综合评分"
        case .budget:      return "预算优先"
        case .distance:    return "距离优先"
        case .area:        return "面积优先"
        case .newest:      return "最新房源"
        case .lowestPrice: return "价格最低"
        }
    }

    var icon: String {
        switch self {
        case .overall:     return "star.fill"
        case .budget:      return "yensign.circle"
        case .distance:    return "location.fill"
        case .area:        return "ruler"
        case .newest:      return "clock"
        case .lowestPrice: return "arrow.down.circle"
        }
    }
}

/// 分数筛选档位
enum MatchScoreThreshold: Int, CaseIterable, Identifiable {
    case all = 0
    case s80 = 80
    case s90 = 90
    case s95 = 95

    var id: Int { rawValue }
    var displayName: String {
        switch self {
        case .all: return "全部"
        case .s80: return "80 分+"
        case .s90: return "90 分+"
        case .s95: return "95 分+"
        }
    }
}
