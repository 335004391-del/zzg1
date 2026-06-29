import Foundation

/// 仪表盘统计数据模型 — 首页数据概览
struct DashboardStat: Codable, Hashable {

    // MARK: - 客户统计

    /// 总客户数
    var customerCount: Int
    /// 高意向客户数（成交概率 ≥60%）
    var highProbabilityCustomer: Int
    /// 预警客户数（即将流失，需重点跟进）
    var warningCustomer: Int

    // MARK: - 房源统计

    /// 在售房源总数
    var houseCount: Int

    // MARK: - 今日数据

    /// 今日跟进次数
    var todayFollow: Int
    /// 今日新增客户
    var todayNewCustomer: Int
    /// 今日新增房源
    var todayNewHouse: Int

    // MARK: - 业绩指标

    /// 匹配成功率（0~1）
    var matchSuccessRate: Double
    /// 本月成交套数
    var monthlyDealCount: Int
    /// 本月新增客户
    var monthlyNewCustomer: Int

    // MARK: - 计算属性

    /// 匹配成功率百分比展示
    var matchSuccessRatePercent: Int { Int(matchSuccessRate * 100) }
}

// MARK: - 周期统计趋势（折线图数据）

struct StatTrendPoint: Codable, Identifiable, Hashable {
    var id: String { date }
    /// 日期字符串（如 "2024-01-01"）
    var date: String
    /// 新增客户数
    var newCustomers: Int
    /// 跟进次数
    var follows: Int
    /// 成交数
    var deals: Int
}

/// 时间周期选择
enum StatPeriod: String, CaseIterable {
    case week  = "week"   // 近 7 天
    case month = "month"  // 近 30 天
    case quarter = "quarter" // 近 90 天

    var displayName: String {
        switch self {
        case .week:    return "近 7 天"
        case .month:   return "近 30 天"
        case .quarter: return "近 3 个月"
        }
    }
}
