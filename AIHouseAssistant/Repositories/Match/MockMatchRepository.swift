import Foundation

/// Mock 匹配仓储 — 返回本地 MockData 匹配结果，用于开发阶段 / Preview
final class MockMatchRepository: MatchRepositoryProtocol {

    func match(customerId: String) async throws -> [MatchListItem] {
        try await simulateDelay(1.0)  // AI 匹配模拟较长延迟
        return makeListItems(for: customerId)
    }

    func recommend(customerId: String, limit: Int) async throws -> [MatchListItem] {
        try await simulateDelay(0.8)
        return Array(makeListItems(for: customerId).prefix(limit))
    }

    // MARK: - 私有辅助

    private func makeListItems(for customerId: String) -> [MatchListItem] {
        MockData.houses.map { house in
            MatchListItem(
                id:          "\(customerId)-\(house.id)",
                customerId:  customerId,
                house:       house,
                matchScore:  Double.random(in: 60...95),
                matchLevel:  .good,
                shortReason: "预算、地段、户型均高度匹配",
                createdAt:   Date()
            )
        }
    }

    private func simulateDelay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
