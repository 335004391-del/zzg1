import Foundation

/// API 路由常量 — 所有接口路径统一维护
enum APIEndpoints {

    // MARK: - 认证
    enum Auth {
        static let login   = "/api/v1/auth/login"
        static let logout  = "/api/v1/auth/logout"
        static let refresh = "/api/v1/auth/refresh"
    }

    // MARK: - 客户
    enum Customer {
        static let list   = "/api/v1/customers"
        static let detail = "/api/v1/customers/%@"  // %@ = customerId
        static let create = "/api/v1/customers"
        static let update = "/api/v1/customers/%@"
        static let delete = "/api/v1/customers/%@"
        static let import_ = "/api/v1/customers/import"
    }

    // MARK: - 房源
    enum House {
        static let list   = "/api/v1/houses"
        static let detail = "/api/v1/houses/%@"
        static let create = "/api/v1/houses"
        static let update = "/api/v1/houses/%@"
        static let delete = "/api/v1/houses/%@"
        static let import_ = "/api/v1/houses/import"
    }

    // MARK: - AI
    enum AI {
        static let customerProfile = "/api/v1/ai/customer-profile"
        static let houseProfile    = "/api/v1/ai/house-profile"
        static let match           = "/api/v1/ai/match"
        static let recommend       = "/api/v1/ai/recommend"
    }

    // MARK: - 仪表盘
    enum Dashboard {
        static let summary = "/api/v1/dashboard/summary"
    }
}
