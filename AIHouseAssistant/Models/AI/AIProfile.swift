import Foundation

/// AI 客户画像模型 — 由 AI 分析生成，描述客户的深层购房特征
struct AIProfile: Codable, Identifiable, Hashable {

    // MARK: - 关联

    /// 画像唯一 ID
    var id: String
    /// 对应客户 ID
    var customerId: String

    // MARK: - AI 分析结果

    /// 客户综合总结（AI 生成的一段描述）
    var summary: String
    /// 性格标签（如"理性决策型"、"情感驱动型"）
    var personality: String
    /// 购房动机深度分析
    var purchasePurpose: String
    /// 价格敏感度
    var priceSensitivity: PriceSensitivity
    /// 偏好房型风格（如"现代简约"、"中式传统"）
    var preferredStyle: String?
    /// 偏好地理位置特征（AI 总结）
    var preferredLocation: String?
    /// 家庭结构分析（如"三代同堂，重视空间"）
    var familyAnalysis: String?

    // MARK: - 风险评估

    /// 流失风险等级
    var riskLevel: RiskLevel
    /// 成交概率（0~1）
    var purchaseProbability: Double

    // MARK: - AI 建议

    /// 给销售的跟进建议
    var aiSuggestion: String
    /// 关键突破点（销售话术方向）
    var keyBreakthrough: [String]
    /// 需要规避的话题
    var avoidTopics: [String]

    // MARK: - 时间

    /// 最近更新时间（AI 重新分析时刷新）
    var lastUpdated: Date

    // MARK: - 计算属性

    /// 成交概率百分比展示
    var probabilityPercent: Int { Int(purchaseProbability * 100) }

    /// 成交概率等级描述
    var probabilityDescription: String {
        switch purchaseProbability {
        case 0.8...:       return "极高"
        case 0.6..<0.8:    return "较高"
        case 0.4..<0.6:    return "中等"
        case 0.2..<0.4:    return "较低"
        default:           return "很低"
        }
    }
}

/// AI 房源画像模型 — 由 AI 分析生成，描述房源核心价值
struct AIHouseProfile: Codable, Identifiable, Hashable {

    var id: String
    /// 对应房源 ID
    var houseId: String
    /// 房源价值综合总结
    var summary: String
    /// 核心竞争力
    var coreStrengths: [String]
    /// 潜在弱点
    var weaknesses: [String]
    /// 最适合人群描述
    var targetCustomer: String
    /// 销售话术建议
    var salesPitch: String
    /// 最近更新时间
    var lastUpdated: Date
}
