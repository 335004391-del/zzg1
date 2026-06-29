import Foundation

/// 首页聚合数据模型 —— 一次性承载 Dashboard 所需的全部数据
/// 由 DashboardRepository 提供，ViewModel 持有，View 只读渲染
struct DashboardOverview: Codable {

    /// 用户称呼（如 "张经理"）
    var userName: String
    /// 今日统计卡片
    var stats: [DashboardStatItem]
    /// AI 今日建议
    var aiSuggestion: DashboardAISuggestion
    /// 待跟进客户
    var followUps: [DashboardFollowUp]
    /// 最新房源（复用 House 模型）
    var latestHouses: [House]
    /// AI 推荐（客户 → 房源 → 匹配度）
    var recommendations: [DashboardRecommendation]
}

// MARK: - 统计卡片

/// 统计卡片配色语义（与 Design System 解耦，View 层映射为具体颜色）
enum DashboardStatAccent: String, Codable {
    case blue, green, orange, purple, red, gold
}

/// 单个统计卡片数据
struct DashboardStatItem: Identifiable, Codable {
    /// 稳定标识（同时作为 Identifiable.id）
    let key: String
    /// 标题（如 "今日新增客户"）
    let title: String
    /// 数值（如 "12"）
    let value: String
    /// 单位（如 "人" / "套" / "万"）
    let unit: String
    /// 图标（SF Symbol）
    let icon: String
    /// 配色语义
    let accent: DashboardStatAccent

    var id: String { key }
}

// MARK: - AI 今日建议

/// AI 今日建议数据
struct DashboardAISuggestion: Codable {
    /// 关联客户 ID
    let customerId: String
    /// 客户称呼（如 "张先生"）
    let customerName: String
    /// 成交概率（0~100）
    let dealProbability: Int
    /// 推荐原因（逐条）
    let reasons: [String]
}

// MARK: - 待跟进客户

/// 待跟进客户摘要
struct DashboardFollowUp: Identifiable, Codable {
    /// 客户 ID（同时作为 Identifiable.id）
    let id: String
    /// 姓名
    let name: String
    /// 预算描述（如 "200~320 万"）
    let budget: String
    /// 需求区域（如 "浦东新区"）
    let area: String
    /// 最后联系时间描述（如 "2 天前"）
    let lastContact: String
    /// 成交概率（0~100）
    let dealProbability: Int

    /// 头像占位首字
    var avatarText: String { String(name.prefix(1)) }
}

// MARK: - AI 推荐

/// AI 推荐项（客户 → 房源 → 匹配度）
struct DashboardRecommendation: Identifiable, Codable {
    /// 推荐 ID（同时作为 Identifiable.id，可用于 AIReport 跳转）
    let id: String
    /// 客户 ID
    let customerId: String
    /// 客户称呼（如 "李女士"）
    let customerName: String
    /// 房源 ID
    let houseId: String
    /// 房源名称（如 "万科·未来城"）
    let houseName: String
    /// 匹配度（0~100）
    let matchScore: Int
}

// MARK: - 快捷功能（纯 UI 配置，不参与网络数据）

/// 首页快捷功能入口
enum DashboardQuickAction: Int, CaseIterable, Identifiable {
    case customer       // 客户管理
    case house          // 房源管理
    case match          // AI 匹配
    case excelImport    // Excel 导入
    case todo           // 今日待办
    case ranking        // 销售排行
    case bossView       // 老板驾驶舱（占位）
    case settings       // 系统设置

    var id: Int { rawValue }

    /// 标题
    var title: String {
        switch self {
        case .customer:    return "客户管理"
        case .house:       return "房源管理"
        case .match:       return "AI 匹配"
        case .excelImport: return "Excel 导入"
        case .todo:        return "今日待办"
        case .ranking:     return "销售排行"
        case .bossView:    return "老板驾驶舱"
        case .settings:    return "系统设置"
        }
    }

    /// 图标（SF Symbol）
    var icon: String {
        switch self {
        case .customer:    return "person.2.fill"
        case .house:       return "building.2.fill"
        case .match:       return "sparkles"
        case .excelImport: return "tablecells.fill"
        case .todo:        return "checklist"
        case .ranking:     return "chart.bar.fill"
        case .bossView:    return "chart.line.uptrend.xyaxis"
        case .settings:    return "gearshape.fill"
        }
    }

    /// 配色语义
    var accent: DashboardStatAccent {
        switch self {
        case .customer:    return .blue
        case .house:       return .green
        case .match:       return .purple
        case .excelImport: return .orange
        case .todo:        return .gold
        case .ranking:     return .red
        case .bossView:    return .purple
        case .settings:    return .blue
        }
    }
}

// MARK: - Mock 数据（供 Mock Repository 与 Preview 共用）

extension DashboardOverview {

    /// 首页示例数据 —— 全部为本地 Mock，禁止用于生产
    static var mock: DashboardOverview {
        DashboardOverview(
            userName: "张经理",
            stats: [
                .init(key: "newCustomer", title: "今日新增客户", value: "12", unit: "人",
                      icon: "person.badge.plus", accent: .blue),
                .init(key: "newHouse", title: "今日新增房源", value: "36", unit: "套",
                      icon: "house.fill", accent: .green),
                .init(key: "followUp", title: "待跟进客户", value: "18", unit: "人",
                      icon: "bell.badge.fill", accent: .orange),
                .init(key: "aiRecommend", title: "AI 推荐数量", value: "42", unit: "个",
                      icon: "sparkles", accent: .purple),
                .init(key: "expectDeal", title: "预计成交客户", value: "6", unit: "人",
                      icon: "checkmark.seal.fill", accent: .red),
                .init(key: "expectAmount", title: "预计成交金额", value: "980", unit: "万",
                      icon: "yensign.circle.fill", accent: .gold),
            ],
            aiSuggestion: DashboardAISuggestion(
                customerId: "c-001",
                customerName: "张先生",
                dealProbability: 92,
                reasons: [
                    "昨天浏览了 8 套房源",
                    "预算明确，付款能力强",
                    "最近回复积极，意向上升",
                ]
            ),
            followUps: [
                .init(id: "c-001", name: "张伟", budget: "200~320 万",
                      area: "浦东新区", lastContact: "2 天前", dealProbability: 92),
                .init(id: "c-002", name: "李梅", budget: "350~500 万",
                      area: "静安区", lastContact: "今天", dealProbability: 78),
                .init(id: "c-003", name: "王建国", budget: "150~220 万",
                      area: "闵行区", lastContact: "3 天前", dealProbability: 65),
                .init(id: "c-004", name: "赵敏", budget: "280~400 万",
                      area: "徐汇区", lastContact: "5 天前", dealProbability: 58),
                .init(id: "c-005", name: "陈强", budget: "600~800 万",
                      area: "黄浦区", lastContact: "1 周前", dealProbability: 49),
            ],
            latestHouses: MockData.houses,
            recommendations: [
                .init(id: "r-001", customerId: "c-002", customerName: "李女士",
                      houseId: "h-001", houseName: "万科·未来城", matchScore: 96),
                .init(id: "r-002", customerId: "c-001", customerName: "张先生",
                      houseId: "h-002", houseName: "绿城·玉兰花园", matchScore: 91),
            ]
        )
    }
}
