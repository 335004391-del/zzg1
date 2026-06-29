import Foundation

/// 仪表盘仓储协议 — 定义业务数据统计与趋势操作接口
protocol DashboardRepositoryProtocol {

    /// 获取首页聚合数据（统计 / AI 建议 / 待跟进 / 房源 / 推荐）
    func overview() async throws -> DashboardOverview

    /// 获取业务汇总统计数据
    func summary() async throws -> DashboardStat

    /// 获取指定时间段的趋势数据
    func trend(period: StatPeriod) async throws -> [StatTrendPoint]
}
