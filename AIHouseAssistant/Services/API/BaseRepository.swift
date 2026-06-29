import Foundation

/// 基础仓储协议 — 为所有具体仓储提供公共网络请求能力
protocol BaseRepository {
    var apiClient: APIClient { get }
}

// MARK: - 默认实现

extension BaseRepository {

    /// 发起请求并解码结果
    func fetch<T: Decodable>(_ endpoint: some APIEndpoint) async throws -> T {
        try await apiClient.request(endpoint)
    }

    /// 发起无返回值请求（删除等操作）
    func fetchVoid(_ endpoint: some APIEndpoint) async throws {
        try await apiClient.requestVoid(endpoint)
    }

    /// 带指数退避重试的请求 — 适用于网络不稳定场景
    func fetchWithRetry<T: Decodable>(
        _ endpoint: some APIEndpoint,
        maxRetries: Int = AppConfig.maxRetryCount
    ) async throws -> T {
        var lastError: Error = APIError.unknown(nil)
        for attempt in 0..<maxRetries {
            do {
                return try await apiClient.request(endpoint)
            } catch let error as APIError where error.isRetryable {
                lastError = error
                // 指数退避：1s / 2s / 4s
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                try await Task.sleep(nanoseconds: delay)
                AppLogger.debug("请求重试 \(attempt + 1)/\(maxRetries): \(endpoint.path)", category: .network)
            } catch {
                throw error
            }
        }
        throw lastError
    }
}

// MARK: - 通用带 Body 的端点包装器

/// 在不修改 AppEndpoint 的前提下，为任意端点附加请求体
struct BodyEndpoint: APIEndpoint {
    let path:         String
    let method:       HTTPMethod
    let queryItems:   [URLQueryItem]?
    let requiresAuth: Bool
    let body:         Encodable?

    init(
        path: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) {
        self.path         = path
        self.method       = method
        self.body         = body
        self.queryItems   = queryItems
        self.requiresAuth = requiresAuth
    }
}
