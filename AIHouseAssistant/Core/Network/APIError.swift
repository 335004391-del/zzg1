import Foundation

/// 统一 API 错误类型 — 覆盖所有网络及业务异常
enum APIError: LocalizedError, Equatable {

    // MARK: - 网络层错误

    /// 无效 URL
    case invalidURL
    /// 无网络连接
    case noNetwork
    /// 请求超时
    case timeout
    /// SSL/TLS 证书错误
    case sslError

    // MARK: - HTTP 状态码错误

    /// 未授权（Token 过期或未登录）—— 需要重新登录
    case unauthorized
    /// 无权限（角色不够）
    case forbidden
    /// 资源不存在
    case notFound
    /// 服务器内部错误
    case serverError(Int)
    /// 其他 HTTP 错误
    case httpError(Int)

    // MARK: - 数据层错误

    /// JSON 解码失败
    case decodingError(String)
    /// 响应体为空
    case emptyResponse
    /// 业务错误（后端返回 code != 0）
    case businessError(code: Int, message: String)

    // MARK: - 其他

    /// 未知错误
    case unknown(Error?)

    // MARK: - 错误描述

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "无效的请求地址"
        case .noNetwork:             return "无网络连接，请检查网络设置"
        case .timeout:               return "请求超时，请稍后重试"
        case .sslError:              return "网络安全验证失败"
        case .unauthorized:          return "登录已过期，请重新登录"
        case .forbidden:             return "您没有权限执行此操作"
        case .notFound:              return "请求的资源不存在"
        case .serverError(let code): return "服务器错误（\(code)），请稍后重试"
        case .httpError(let code):   return "网络错误（\(code)）"
        case .decodingError(let msg): return "数据解析失败：\(msg)"
        case .emptyResponse:         return "服务器返回空响应"
        case .businessError(_, let msg): return msg
        case .unknown(let err):      return err?.localizedDescription ?? "未知错误，请稍后重试"
        }
    }

    /// 是否需要退出登录
    var requiresLogout: Bool { self == .unauthorized }

    /// 是否可以重试
    var isRetryable: Bool {
        switch self {
        case .timeout, .serverError, .noNetwork: return true
        default: return false
        }
    }

    // MARK: - Equatable

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
}
