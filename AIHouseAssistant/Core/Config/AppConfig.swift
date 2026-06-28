import Foundation

/// 全局配置中心 — 所有环境变量、服务地址统一管理
enum AppConfig {

    // MARK: - 环境

    /// 当前运行环境
    static var environment: Environment = .development

    enum Environment {
        case development
        case staging
        case production
    }

    // MARK: - 版本信息

    /// App 版本号
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    /// Build 号
    static let buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // MARK: - 后端服务地址

    /// API 基础地址
    static var apiBaseURL: String {
        switch environment {
        case .development:  return "http://localhost:8000"
        case .staging:      return "https://staging-api.aihouseassistant.com"
        case .production:   return "https://api.aihouseassistant.com"
        }
    }

    /// AI 服务地址
    static var aiServiceURL: String {
        switch environment {
        case .development:  return "http://localhost:8001"
        case .staging:      return "https://staging-ai.aihouseassistant.com"
        case .production:   return "https://ai.aihouseassistant.com"
        }
    }

    // MARK: - 网络配置

    /// 请求超时时间（秒）
    static let requestTimeout: TimeInterval = 30

    /// 最大重试次数
    static let maxRetryCount: Int = 3

    // MARK: - AI 配置

    /// 默认 AI 模型提供商
    static var aiProvider: AIProvider = .openAI

    enum AIProvider: String {
        case openAI   = "openai"
        case claude   = "claude"
        case gemini   = "gemini"
        case deepSeek = "deepseek"
        case qwen     = "qwen"
        case moonshot = "moonshot"
    }

    // MARK: - 分页

    /// 默认每页数量
    static let defaultPageSize: Int = 20

    // MARK: - 缓存

    /// 本地缓存有效期（秒）
    static let cacheTTL: TimeInterval = 60 * 10 // 10 分钟
}
