import Foundation

/// Mock 仪表盘仓储 — 返回本地 MockData 统计数据，用于开发阶段 / Preview
final class MockDashboardRepository: DashboardRepositoryProtocol {

    func summary() async throws -> DashboardStat {
        try await simulateDelay()
        return MockData.dashboardStat
    }

    func trend(period: StatPeriod) async throws -> [StatTrendPoint] {
        try await simulateDelay()
        let days: Int
        switch period {
        case .week:    days = 7
        case .month:   days = 30
        case .quarter: days = 90
        }
        // 生成模拟趋势数据
        return (0..<days).map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let fmt  = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            return StatTrendPoint(
                date:        fmt.string(from: date),
                newCustomers: Int.random(in: 0...5),
                follows:      Int.random(in: 2...12),
                deals:        Int.random(in: 0...2)
            )
        }.reversed()
    }

    private func simulateDelay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
