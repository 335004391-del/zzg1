import Foundation

// MARK: - 性别

enum Gender: String, Codable, CaseIterable, Hashable {
    case male   = "male"
    case female = "female"
    case other  = "other"

    var displayName: String {
        switch self {
        case .male:   return "男"
        case .female: return "女"
        case .other:  return "其他"
        }
    }

    var icon: String {
        switch self {
        case .male:   return "person.fill"
        case .female: return "person.fill"
        case .other:  return "person.fill"
        }
    }
}

// MARK: - 用户角色

enum UserRole: String, Codable, CaseIterable, Hashable {
    case admin     = "admin"      // 超级管理员
    case manager   = "manager"    // 门店经理
    case sales     = "sales"      // 置业顾问
    case assistant = "assistant"  // 销售助理

    var displayName: String {
        switch self {
        case .admin:     return "超级管理员"
        case .manager:   return "门店经理"
        case .sales:     return "置业顾问"
        case .assistant: return "销售助理"
        }
    }

    /// 是否具有管理权限
    var hasManagePermission: Bool {
        self == .admin || self == .manager
    }
}

// MARK: - 用户状态

enum UserStatus: String, Codable, CaseIterable, Hashable {
    case active   = "active"    // 在职
    case inactive = "inactive"  // 离职
    case pending  = "pending"   // 待激活

    var displayName: String {
        switch self {
        case .active:   return "在职"
        case .inactive: return "离职"
        case .pending:  return "待激活"
        }
    }
}
