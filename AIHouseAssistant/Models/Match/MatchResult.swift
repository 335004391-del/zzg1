import Foundation

/// AI 匹配结果模型 — 记录客户与房源的匹配分析
struct MatchResult: Codable, Identifiable, Hashable {

    // MARK: - 基础

    /// 系统唯一 ID
    var id: String
    /// 对应客户 ID
    var customerId: String
    /// 对应房源 ID
    var houseId: String

    // MARK: - 综合评分（0~100）

    /// 综合匹配分（加权）
    var matchScore: Double

    // MARK: - 分项评分（0~100）

    /// 预算匹配分
    var budgetScore: Double
    /// 地理位置匹配分
    var locationScore: Double
    /// 面积匹配分
    var areaScore: Double
    /// 户型匹配分
    var layoutScore: Double
    /// 标签匹配分（学区、地铁等）
    var tagScore: Double
    /// AI 综合评分（结合画像）
    var aiScore: Double

    // MARK: - AI 推荐理由

    /// AI 生成的推荐说明（面向销售）
    var reason: String
    /// 简短推荐语（面向客户展示）
    var shortReason: String?
    /// 不匹配风险点（需销售注意）
    var riskPoints: [String]

    // MARK: - 时间

    /// 匹配生成时间
    var createdAt: Date

    // MARK: - 计算属性

    /// 匹配等级
    var matchLevel: MatchLevel {
        switch matchScore {
        case 80...:  return .excellent
        case 60..<80: return .good
        case 40..<60: return .fair
        default:      return .poor
        }
    }

    /// 匹配分百分比（0~1）
    var matchRatio: Double { matchScore / 100.0 }
}

// MARK: - 匹配等级

enum MatchLevel: String, Codable, CaseIterable, Hashable {
    case excellent = "excellent"  // 高度匹配（80+）
    case good      = "good"       // 良好匹配（60~79）
    case fair      = "fair"       // 一般匹配（40~59）
    case poor      = "poor"       // 低匹配（<40）

    var displayName: String {
        switch self {
        case .excellent: return "高度匹配"
        case .good:      return "良好匹配"
        case .fair:      return "一般匹配"
        case .poor:      return "低匹配"
        }
    }

    var color: String {
        switch self {
        case .excellent: return "success"
        case .good:      return "primary"
        case .fair:      return "warning"
        case .poor:      return "error"
        }
    }
}

// MARK: - 匹配列表项（客户下的房源匹配摘要）

struct MatchListItem: Codable, Identifiable, Hashable {
    var id: String
    var customerId: String
    var house: House
    var matchScore: Double
    var matchLevel: MatchLevel
    var shortReason: String
    var createdAt: Date
}
