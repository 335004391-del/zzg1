import Foundation

/// Mock 客户仓储 — 返回本地 MockData，用于开发阶段 / Preview / 单元测试
final class MockCustomerRepository: CustomerRepositoryProtocol {

    // MARK: - 客户列表与详情

    func list(page: PageRequest) async throws -> PageResponse<Customer> {
        try await simulateDelay()
        var items = MockData.customers
        // 关键词过滤
        if let keyword = page.keyword, !keyword.isEmpty {
            items = items.filter {
                $0.name.contains(keyword) || $0.phone.contains(keyword)
            }
        }
        let total   = items.count
        let start   = (page.page - 1) * page.pageSize
        let end     = min(start + page.pageSize, total)
        let paged   = start < total ? Array(items[start..<end]) : []
        return PageResponse(
            items:    paged,
            total:    total,
            page:     page.page,
            pageSize: page.pageSize,
            hasMore:  end < total
        )
    }

    func detail(id: String) async throws -> Customer {
        try await simulateDelay()
        guard let customer = MockData.customers.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return customer
    }

    // MARK: - 客户写操作（本地模拟）

    func create(_ customer: Customer) async throws -> Customer {
        try await simulateDelay()
        // Mock 直接返回带生成 ID 的客户
        var created    = customer
        created.id     = UUID().uuidString
        return created
    }

    func update(_ customer: Customer) async throws -> Customer {
        try await simulateDelay()
        return customer
    }

    func delete(id: String) async throws {
        try await simulateDelay()
        // Mock 不做实际删除
    }

    // MARK: - 跟进记录

    func follows(customerId: String, page: PageRequest) async throws -> PageResponse<FollowRecord> {
        try await simulateDelay()
        let records = MockData.followRecords.filter { $0.customerId == customerId }
        return PageResponse(
            items:    records,
            total:    records.count,
            page:     1,
            pageSize: page.pageSize,
            hasMore:  false
        )
    }

    func createFollow(_ record: FollowRecord, customerId: String) async throws -> FollowRecord {
        try await simulateDelay()
        var created      = record
        created.id       = UUID().uuidString
        created.customerId = customerId
        return created
    }

    func deleteFollow(id: String) async throws {
        try await simulateDelay()
    }

    // MARK: - 网络模拟延迟

    private func simulateDelay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
