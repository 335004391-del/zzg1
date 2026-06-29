import Foundation

/// API 客户端 — 统一负责所有 HTTP 请求
/// 支持 async/await / Token 自动注入 / 401 刷新重试 / 错误映射 / 日志
actor APIClient {

    // MARK: - 单例

    static let shared = APIClient()

    // MARK: - 依赖

    private let session:      URLSession
    private let tokenManager: TokenManager

    // MARK: - 初始化

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = AppConfig.requestTimeout
        config.timeoutIntervalForResource = AppConfig.requestTimeout * 2
        self.session      = URLSession(configuration: config)
        self.tokenManager = TokenManager.shared
    }

    // MARK: - 公开请求 API

    /// 发起请求并解码 APIResponse.data 字段
    func request<T: Decodable>(_ endpoint: some APIEndpoint) async throws -> T {
        let raw      = try await execute(endpoint: endpoint, retryOnUnauth: true)
        let envelope = try decode(APIResponse<T>.self, from: raw)
        guard envelope.isSuccess, let payload = envelope.data else {
            throw APIError.businessError(code: envelope.code, message: envelope.message)
        }
        return payload
    }

    /// 发起无返回值请求（如删除操作）
    func requestVoid(_ endpoint: some APIEndpoint) async throws {
        let raw      = try await execute(endpoint: endpoint, retryOnUnauth: true)
        let envelope = try decode(APIResponse<EmptyPayload>.self, from: raw)
        guard envelope.isSuccess else {
            throw APIError.businessError(code: envelope.code, message: envelope.message)
        }
    }

    // MARK: - 内部执行

    private func execute(endpoint: some APIEndpoint, retryOnUnauth: Bool) async throws -> Data {
        // 检查网络连接状态（NetworkMonitor 在 @MainActor，需要跨 Actor 访问）
        let online = await MainActor.run { NetworkMonitor.shared.isConnected }
        guard online else { throw APIError.noNetwork }

        let req = try buildRequest(from: endpoint)
        logRequest(req)

        do {
            let (data, response) = try await session.data(for: req)
            return try await handleHTTP(
                data: data,
                response: response,
                endpoint: endpoint,
                retryOnUnauth: retryOnUnauth
            )
        } catch let error as APIError {
            throw error
        } catch let urlError as URLError {
            throw mapURLError(urlError)
        } catch {
            throw APIError.unknown(error)
        }
    }

    private func handleHTTP(
        data: Data,
        response: URLResponse,
        endpoint: some APIEndpoint,
        retryOnUnauth: Bool
    ) async throws -> Data {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.emptyResponse
        }
        logResponse(status: http.statusCode, path: endpoint.path)

        switch http.statusCode {
        case 200...299:
            return data
        case 401:
            // 尝试刷新 Token 后重试一次
            if retryOnUnauth {
                try await refreshToken()
                return try await execute(endpoint: endpoint, retryOnUnauth: false)
            }
            throw APIError.unauthorized
        case 403: throw APIError.forbidden
        case 404: throw APIError.notFound
        case 500...599: throw APIError.serverError(http.statusCode)
        default: throw APIError.httpError(http.statusCode)
        }
    }

    // MARK: - 构造 URLRequest

    private func buildRequest(from endpoint: some APIEndpoint) throws -> URLRequest {
        guard var components = URLComponents(string: AppConfig.apiBaseURL + endpoint.path) else {
            throw APIError.invalidURL
        }
        if let items = endpoint.queryItems, !items.isEmpty {
            components.queryItems = items
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var req             = URLRequest(url: url)
        req.httpMethod      = endpoint.method.rawValue
        req.timeoutInterval = AppConfig.requestTimeout
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue(AppConfig.appVersion, forHTTPHeaderField: "X-App-Version")

        // 注入 Bearer Token
        if endpoint.requiresAuth, let token = tokenManager.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 序列化请求体
        if let body = endpoint.body {
            req.httpBody = try JSONEncoder.app.encode(AnyEncodable(body))
        }
        return req
    }

    // MARK: - Token 刷新

    private func refreshToken() async throws {
        guard let refreshToken = tokenManager.refreshToken else {
            throw APIError.unauthorized
        }

        guard let url = URL(string: AppConfig.apiBaseURL + "/api/v1/auth/refresh") else {
            throw APIError.invalidURL
        }
        var req = URLRequest(url: url)
        req.httpMethod = HTTPMethod.post.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder.app.encode(["refresh_token": refreshToken])

        let (data, _)  = try await session.data(for: req)
        let envelope   = try decode(APIResponse<TokenPair>.self, from: data)
        guard envelope.isSuccess, let pair = envelope.data else {
            throw APIError.unauthorized
        }

        tokenManager.saveAccessToken(pair.accessToken)
        tokenManager.saveRefreshToken(pair.refreshToken)
        AppLogger.info("Token 刷新成功", category: .network)
    }

    // MARK: - JSON 解码

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder.app.decode(type, from: data)
        } catch {
            AppLogger.error("JSON 解码失败 [\(T.self)]: \(error)", category: .network)
            throw APIError.decodingError(error.localizedDescription)
        }
    }

    // MARK: - URLError 映射

    private func mapURLError(_ error: URLError) -> APIError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noNetwork
        case .timedOut:
            return .timeout
        case .serverCertificateUntrusted, .clientCertificateRejected:
            return .sslError
        default:
            return .unknown(error)
        }
    }

    // MARK: - 日志

    private func logRequest(_ req: URLRequest) {
        AppLogger.debug(
            "→ \(req.httpMethod ?? "?") \(req.url?.relativePath ?? "")",
            category: .network
        )
    }

    private func logResponse(status: Int, path: String) {
        AppLogger.debug("← \(status) \(path)", category: .network)
    }
}

// MARK: - 私有辅助类型

/// 无数据响应占位（删除等操作）
private struct EmptyPayload: Decodable {}

/// Token 对（刷新接口响应）
private struct TokenPair: Decodable {
    let accessToken: String
    let refreshToken: String
}

/// 类型擦除 Encodable 包装器 — 解决 Encodable? 无法直接传入 encode 的限制
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ wrapped: Encodable) { self._encode = wrapped.encode }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
