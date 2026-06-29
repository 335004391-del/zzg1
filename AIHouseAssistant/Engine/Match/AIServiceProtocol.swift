import Foundation

/// AI 服务协议 —— 为 V2 升级预留的统一抽象
/// 第一版采用规则引擎（MatchEngine），不接入任何 AI。
/// 未来可由 OpenAI / Claude / DeepSeek / Gemini / Qwen / Moonshot 等实现，
/// 替换实现即可增强匹配，无需修改 MatchEngine。
protocol AIServiceProtocol {

    /// AI 提供商标识
    var provider: AppConfig.AIProvider { get }

    /// 对规则引擎产出的推荐进行 AI 增强（重排序 / 生成更自然的理由）
    /// - Parameters:
    ///   - customer: 目标客户
    ///   - recommendations: 规则引擎产出的初步推荐
    /// - Returns: 增强后的推荐列表
    func enhance(customer: Customer,
                 recommendations: [MatchRecommendation]) async throws -> [MatchRecommendation]

    /// 为单个房源生成 AI 推荐文案（预留）
    func generateReason(customer: Customer, house: House) async throws -> String
}

// MARK: - 默认空实现（占位，V1 不启用）

/// 规则引擎直通实现 —— V1 默认，不做任何 AI 处理
struct RuleBasedAIService: AIServiceProtocol {
    var provider: AppConfig.AIProvider { AppConfig.aiProvider }

    func enhance(customer: Customer,
                 recommendations: [MatchRecommendation]) async throws -> [MatchRecommendation] {
        // V1 直接返回规则引擎结果
        recommendations
    }

    func generateReason(customer: Customer, house: House) async throws -> String {
        "（规则引擎）综合匹配良好"
    }
}
