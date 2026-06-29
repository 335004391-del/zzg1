import Foundation

/// 仪表盘仓储 — 通过 APIClient 获取业务统计数据
final class DashboardRepository: DashboardRepositoryProtocol, BaseRepository {

    // MARK: - 依赖

    let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - 首页聚合数据

    func overview() async throws -> DashboardOverview {
        try await fetch(AppEndpoint.Dashboard.overview)
    }

    // MARK: - 统计数据

    func summary() async throws -> DashboardStat {
        try await fetch(AppEndpoint.Dashboard.summary)
    }

    func trend(period: StatPeriod) async throws -> [StatTrendPoint] {
        try await fetch(AppEndpoint.Dashboard.trend(period: period.rawValue))
    }
}
