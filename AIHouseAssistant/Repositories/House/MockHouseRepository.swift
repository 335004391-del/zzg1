import Foundation

/// Mock 房源仓储 — 返回本地 MockData，用于开发阶段 / Preview / 单元测试
final class MockHouseRepository: HouseRepositoryProtocol {

    // MARK: - 房源列表与详情

    func list(page: PageRequest) async throws -> PageResponse<House> {
        try await simulateDelay()
        var items = MockData.houses
        // 关键词过滤（名称 / 小区）
        if let keyword = page.keyword, !keyword.isEmpty {
            items = items.filter {
                $0.name.contains(keyword) || $0.community.contains(keyword)
            }
        }
        let total  = items.count
        let start  = (page.page - 1) * page.pageSize
        let end    = min(start + page.pageSize, total)
        let paged  = start < total ? Array(items[start..<end]) : []
        return PageResponse(
            items:    paged,
            total:    total,
            page:     page.page,
            pageSize: page.pageSize,
            hasMore:  end < total
        )
    }

    func detail(id: String) async throws -> House {
        try await simulateDelay()
        guard let house = MockData.houses.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return house
    }

    // MARK: - 房源写操作（本地模拟）

    func create(_ house: House) async throws -> House {
        try await simulateDelay()
        var created = house
        created.id  = UUID().uuidString
        return created
    }

    func update(_ house: House) async throws -> House {
        try await simulateDelay()
        return house
    }

    func delete(id: String) async throws {
        try await simulateDelay()
    }

    // MARK: - 网络模拟延迟

    private func simulateDelay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
