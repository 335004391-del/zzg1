import Foundation

/// 应用内全部可导航页面 — 类型安全的目的地定义
/// 新增页面必须在此登记；严禁在跳转时使用字符串或 Any 传参
enum AppDestination: Hashable {

    // MARK: - 仪表盘
    case dashboard

    // MARK: - 客户
    case customerList
    case customerDetail(customerId: String)
    case followRecord(customerId: String)

    // MARK: - 房源
    case houseList
    case houseDetail(houseId: String)

    // MARK: - AI
    case match(customerId: String)
    case aiProfile(customerId: String)
    case aiReport(matchId: String)

    // MARK: - 系统
    case settings
    case profile
    case login
    case splash

    // MARK: - 页面标题（导航栏展示用）

    var title: String {
        switch self {
        case .dashboard:        return "首页"
        case .customerList:     return "客户列表"
        case .customerDetail:   return "客户详情"
        case .followRecord:     return "跟进记录"
        case .houseList:        return "房源列表"
        case .houseDetail:      return "房源详情"
        case .match:            return "智能匹配"
        case .aiProfile:        return "AI 画像"
        case .aiReport:         return "AI 匹配报告"
        case .settings:         return "设置"
        case .profile:          return "我的"
        case .login:            return "登录"
        case .splash:           return "启动"
        }
    }
}

// MARK: - 主 Tab 定义

/// 底部 TabBar 的 5 个主分区
enum AppTab: Int, CaseIterable, Identifiable {
    case dashboard  // 首页
    case customer   // 客户
    case house      // 房源
    case ai         // AI
    case profile    // 我的

    var id: Int { rawValue }

    /// Tab 标题
    var title: String {
        switch self {
        case .dashboard: return "首页"
        case .customer:  return "客户"
        case .house:     return "房源"
        case .ai:        return "AI"
        case .profile:   return "我的"
        }
    }

    /// 未选中图标（SF Symbol）
    var icon: String {
        switch self {
        case .dashboard: return "house"
        case .customer:  return "person.2"
        case .house:     return "building.2"
        case .ai:        return "sparkles"
        case .profile:   return "person.crop.circle"
        }
    }

    /// 选中图标（填充态）
    var selectedIcon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .customer:  return "person.2.fill"
        case .house:     return "building.2.fill"
        case .ai:        return "sparkles"
        case .profile:   return "person.crop.circle.fill"
        }
    }

    /// 每个 Tab 的根页面目的地
    var rootDestination: AppDestination {
        switch self {
        case .dashboard: return .dashboard
        case .customer:  return .customerList
        case .house:     return .houseList
        case .ai:        return .match(customerId: "")
        case .profile:   return .profile
        }
    }
}
