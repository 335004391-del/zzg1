import Foundation

/// 网络层统一错误类型
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(Int)
    case httpError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "无效的请求地址"
        case .invalidResponse:      return "无效的服务器响应"
        case .unauthorized:         return "未授权，请重新登录"
        case .notFound:             return "请求的资源不存在"
        case .serverError(let code): return "服务器错误（\(code)）"
        case .httpError(let code):  return "HTTP 错误（\(code)）"
        case .unknown(let error):   return error.localizedDescription
        }
    }
}
