import Foundation

/// 用户模型 — 销售人员账户信息
struct User: Codable, Identifiable, Hashable {

    // MARK: - 基础信息

    /// 系统唯一 ID
    var id: String
    /// 姓名
    var name: String
    /// 头像 URL
    var avatar: String?
    /// 手机号（同时作为登录账号）
    var phone: String
    /// 邮箱
    var email: String?

    // MARK: - 职务

    /// 角色权限
    var role: UserRole
    /// 所属部门
    var department: String?
    /// 所属门店
    var store: String?

    // MARK: - 状态

    /// 账户状态
    var status: UserStatus
    /// 注册时间
    var createdAt: Date

    // MARK: - 计算属性

    /// 显示名称（Avatar 占位用首字）
    var avatarPlaceholder: String {
        String(name.prefix(1))
    }

    /// 是否为管理员
    var isAdmin: Bool { role == .admin }

    /// 是否有管理权限（admin/manager）
    var canManage: Bool { role.hasManagePermission }
}

// MARK: - User Extension

extension User {

    /// 当前登录用户的本地缓存键
    static let currentUserKey = StorageKey.currentUser

    static func guest() -> User {
        User(
            id:         "guest",
            name:       "游客",
            avatar:     nil,
            phone:      "",
            email:      nil,
            role:       .sales,
            department: nil,
            store:      nil,
            status:     .pending,
            createdAt:  Date()
        )
    }
}
