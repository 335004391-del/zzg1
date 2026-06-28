import Foundation

/// 网络请求统一管理器
/// 负责所有 HTTP 请求的发送、错误处理、重试逻辑
final class NetworkManager: Sendable {

    // MARK: - 单例

    static let shared = NetworkManager()

    // MARK: - 私有属性

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = AppConfig.requestTimeout
        config.timeoutIntervalForResource = AppConfig.requestTimeout * 2
        config.requestCachePolicy         = .useProtocolCachePolicy
        session = URLSession(configuration: config)
    }

    // MARK: - 通用请求

    /// 发起 GET 请求，返回解码后的模型
    func get<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil
    ) async throws -> T {
        let request = try buildRequest(
            method: "GET",
            endpoint: endpoint,
            queryItems: queryItems,
            headers: headers
        )
        return try await perform(request)
    }

    /// 发起 POST 请求，返回解码后的模型
    func post<T: Decodable, Body: Encodable>(
        endpoint: String,
        body: Body,
        headers: [String: String]? = nil
    ) async throws -> T {
        var request = try buildRequest(method: "POST", endpoint: endpoint, headers: headers)
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    /// 发起 PUT 请求
    func put<T: Decodable, Body: Encodable>(
        endpoint: String,
        body: Body,
        headers: [String: String]? = nil
    ) async throws -> T {
        var request = try buildRequest(method: "PUT", endpoint: endpoint, headers: headers)
        request.httpBody = try JSONEncoder().encode(body)
        return try await perform(request)
    }

    /// 发起 DELETE 请求
    func delete(
        endpoint: String,
        headers: [String: String]? = nil
    ) async throws {
        let request = try buildRequest(method: "DELETE", endpoint: endpoint, headers: headers)
        let _: EmptyResponse = try await perform(request)
    }

    // MARK: - 内部方法

    /// 构建 URLRequest
    private func buildRequest(
        method: String,
        endpoint: String,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil
    ) throws -> URLRequest {
        guard var components = URLComponents(string: AppConfig.apiBaseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // 附加自定义 Header
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        AppLogger.debug("[\(method)] \(url.absoluteString)", category: .network)
        return request
    }

    /// 执行请求并解码
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            AppLogger.debug("HTTP \(httpResponse.statusCode) — \(request.url?.absoluteString ?? "")", category: .network)

            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw NetworkError.unauthorized
            case 404:
                throw NetworkError.notFound
            case 500...599:
                throw NetworkError.serverError(httpResponse.statusCode)
            default:
                throw NetworkError.httpError(httpResponse.statusCode)
            }

            return try JSONDecoder().decode(T.self, from: data)

        } catch let error as NetworkError {
            AppLogger.error("网络请求失败", category: .network, error: error)
            throw error
        } catch {
            AppLogger.error("网络请求异常", category: .network, error: error)
            throw NetworkError.unknown(error)
        }
    }
}

// MARK: - 空响应占位

/// 用于无响应体的请求（DELETE 等）
private struct EmptyResponse: Decodable {}
