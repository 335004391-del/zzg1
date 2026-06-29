import Foundation

/// 客户查询条件 —— 搜索 + 筛选 + 排序 + 分页 的统一载体
/// 商业级设计：所有列表请求都通过此结构，便于未来扩展为后端查询参数
struct CustomerQuery: Equatable {
    /// 关键词（姓名 / 电话 / 微信 / 公司）
    var keyword: String = ""
    /// 筛选条件
    var filter: CustomerFilter = CustomerFilter()
    /// 排序方式
    var sort: CustomerSortOption = .newest
    /// 仅看收藏
    var favoritesOnly: Bool = false
    /// 页码（从 1 开始）
    var page: Int = 1
    /// 每页数量
    var pageSize: Int = 20
}

// MARK: - 筛选条件

/// 客户筛选条件 —— 各维度均可组合
struct CustomerFilter: Equatable {
    /// 客户状态（多选）
    var statuses: Set<CustomerStatus> = []
    /// 客户标签（多选）
    var tags: Set<CustomerTag> = []
    /// 意向区域（多选）
    var areas: Set<String> = []
    /// 预算下限（万元）
    var budgetMin: Double? = nil
    /// 预算上限（万元）
    var budgetMax: Double? = nil
    /// 最低成交概率（0~100）
    var minDealProbability: Int? = nil
    /// 最后联系时间在 N 天内
    var lastContactWithinDays: Int? = nil

    /// 是否为空（未设置任何筛选）
    var isEmpty: Bool {
        statuses.isEmpty && tags.isEmpty && areas.isEmpty &&
        budgetMin == nil && budgetMax == nil &&
        minDealProbability == nil && lastContactWithinDays == nil
    }

    /// 已激活的筛选维度数量（用于角标显示）
    var activeCount: Int {
        var count = 0
        if !statuses.isEmpty { count += 1 }
        if !tags.isEmpty { count += 1 }
        if !areas.isEmpty { count += 1 }
        if budgetMin != nil || budgetMax != nil { count += 1 }
        if minDealProbability != nil { count += 1 }
        if lastContactWithinDays != nil { count += 1 }
        return count
    }
}

// MARK: - 排序方式

/// 客户排序方式
enum CustomerSortOption: String, CaseIterable, Identifiable {
    case newest           // 最新添加
    case recentContact    // 最近联系
    case budgetHigh       // 预算最高
    case dealProbability  // 成交概率
    case nameAZ           // 姓名 A-Z

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newest:          return "最新添加"
        case .recentContact:   return "最近联系"
        case .budgetHigh:      return "预算最高"
        case .dealProbability: return "成交概率"
        case .nameAZ:          return "姓名 A-Z"
        }
    }

    var icon: String {
        switch self {
        case .newest:          return "clock.badge.checkmark"
        case .recentContact:   return "phone.arrow.up.right"
        case .budgetHigh:      return "yensign.circle"
        case .dealProbability: return "chart.line.uptrend.xyaxis"
        case .nameAZ:          return "textformat"
        }
    }
}

// MARK: - 可选区域常量（Mock 阶段固定，未来可由后端下发）

enum CustomerAreaOptions {
    /// 可筛选的意向区域列表
    static let all: [String] = [
        "浦东新区", "静安区", "长宁区", "徐汇区", "黄浦区",
        "闵行区", "杨浦区", "普陀区", "虹口区", "宝山区",
    ]
}
