import Foundation

/// API 端点协议 — 统一描述一个 HTTP 请求的所有要素
protocol APIEndpoint {
    /// 路径（不含 baseURL，以 / 开头）
    var path:        String       { get }
    /// HTTP 方法
    var method:      HTTPMethod   { get }
    /// Query 参数
    var queryItems:  [URLQueryItem]? { get }
    /// 请求体（nil 表示无 body）
    var body:        Encodable?   { get }
    /// 是否需要 Token（默认 true）
    var requiresAuth: Bool        { get }
}

// MARK: - 默认值

extension APIEndpoint {
    var queryItems:  [URLQueryItem]? { nil }
    var body:        Encodable?      { nil }
    var requiresAuth: Bool           { true }
}

// MARK: - 全部接口端点定义

enum AppEndpoint {

    // MARK: - 认证

    enum Auth: APIEndpoint {
        case login(phone: String, password: String)
        case logout
        case refreshToken

        var path: String {
            switch self {
            case .login:        return "/api/v1/auth/login"
            case .logout:       return "/api/v1/auth/logout"
            case .refreshToken: return "/api/v1/auth/refresh"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .login, .refreshToken: return .post
            case .logout:               return .post
            }
        }

        var body: Encodable? {
            switch self {
            case .login(let phone, let password):
                return ["phone": phone, "password": password]
            default:
                return nil
            }
        }

        var requiresAuth: Bool {
            switch self {
            case .login: return false
            default:     return true
            }
        }
    }

    // MARK: - 客户

    enum Customer: APIEndpoint {
        case list(PageRequest)
        case detail(id: String)
        case create
        case update(id: String)
        case delete(id: String)
        case importExcel

        var path: String {
            switch self {
            case .list:            return "/api/v1/customers"
            case .detail(let id):  return "/api/v1/customers/\(id)"
            case .create:          return "/api/v1/customers"
            case .update(let id):  return "/api/v1/customers/\(id)"
            case .delete(let id):  return "/api/v1/customers/\(id)"
            case .importExcel:     return "/api/v1/customers/import"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .list, .detail: return .get
            case .create:        return .post
            case .update:        return .put
            case .delete:        return .delete
            case .importExcel:   return .post
            }
        }

        var queryItems: [URLQueryItem]? {
            switch self {
            case .list(let req): return req.queryItems
            default: return nil
            }
        }
    }

    // MARK: - 房源

    enum House: APIEndpoint {
        case list(PageRequest)
        case detail(id: String)
        case create
        case update(id: String)
        case delete(id: String)
        case importExcel

        var path: String {
            switch self {
            case .list:           return "/api/v1/houses"
            case .detail(let id): return "/api/v1/houses/\(id)"
            case .create:         return "/api/v1/houses"
            case .update(let id): return "/api/v1/houses/\(id)"
            case .delete(let id): return "/api/v1/houses/\(id)"
            case .importExcel:    return "/api/v1/houses/import"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .list, .detail: return .get
            case .create:        return .post
            case .update:        return .put
            case .delete:        return .delete
            case .importExcel:   return .post
            }
        }

        var queryItems: [URLQueryItem]? {
            switch self {
            case .list(let req): return req.queryItems
            default: return nil
            }
        }
    }

    // MARK: - AI

    enum AI: APIEndpoint {
        case customerProfile(customerId: String)
        case houseProfile(houseId: String)
        case match(customerId: String)
        case recommend(customerId: String, limit: Int)

        var path: String {
            switch self {
            case .customerProfile(let id): return "/api/v1/ai/customer-profile/\(id)"
            case .houseProfile(let id):    return "/api/v1/ai/house-profile/\(id)"
            case .match(let id):           return "/api/v1/ai/match/\(id)"
            case .recommend(let id, _):    return "/api/v1/ai/recommend/\(id)"
            }
        }

        var method: HTTPMethod { .post }

        var queryItems: [URLQueryItem]? {
            switch self {
            case .recommend(_, let limit):
                return [URLQueryItem(name: "limit", value: "\(limit)")]
            default:
                return nil
            }
        }
    }

    // MARK: - 仪表盘

    enum Dashboard: APIEndpoint {
        case summary
        case trend(period: String)

        var path: String {
            switch self {
            case .summary:    return "/api/v1/dashboard/summary"
            case .trend:      return "/api/v1/dashboard/trend"
            }
        }

        var method: HTTPMethod { .get }

        var queryItems: [URLQueryItem]? {
            switch self {
            case .trend(let period):
                return [URLQueryItem(name: "period", value: period)]
            default:
                return nil
            }
        }
    }

    // MARK: - 跟进记录

    enum Follow: APIEndpoint {
        case list(customerId: String, page: PageRequest)
        case create(customerId: String)
        case delete(id: String)

        var path: String {
            switch self {
            case .list(let cid, _):  return "/api/v1/customers/\(cid)/follows"
            case .create(let cid):   return "/api/v1/customers/\(cid)/follows"
            case .delete(let id):    return "/api/v1/follows/\(id)"
            }
        }

        var method: HTTPMethod {
            switch self {
            case .list:   return .get
            case .create: return .post
            case .delete: return .delete
            }
        }

        var queryItems: [URLQueryItem]? {
            switch self {
            case .list(_, let req): return req.queryItems
            default: return nil
            }
        }
    }
}
