import Foundation

/// 客户仓储 — 通过 APIClient 执行所有客户数据网络请求
final class CustomerRepository: CustomerRepositoryProtocol, BaseRepository {

    // MARK: - 依赖

    let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - 客户列表与详情

    func list(page: PageRequest) async throws -> PageResponse<Customer> {
        try await fetch(AppEndpoint.Customer.list(page))
    }

    func detail(id: String) async throws -> Customer {
        try await fetch(AppEndpoint.Customer.detail(id: id))
    }

    // MARK: - 客户写操作

    func create(_ customer: Customer) async throws -> Customer {
        let endpoint = BodyEndpoint(
            path: AppEndpoint.Customer.create.path,
            method: .post,
            body: customer
        )
        return try await fetch(endpoint)
    }

    func update(_ customer: Customer) async throws -> Customer {
        let endpoint = BodyEndpoint(
            path: AppEndpoint.Customer.update(id: customer.id).path,
            method: .put,
            body: customer
        )
        return try await fetch(endpoint)
    }

    func delete(id: String) async throws {
        try await fetchVoid(AppEndpoint.Customer.delete(id: id))
    }

    // MARK: - 跟进记录

    func follows(customerId: String, page: PageRequest) async throws -> PageResponse<FollowRecord> {
        try await fetch(AppEndpoint.Follow.list(customerId: customerId, page: page))
    }

    func createFollow(_ record: FollowRecord, customerId: String) async throws -> FollowRecord {
        let endpoint = BodyEndpoint(
            path: AppEndpoint.Follow.create(customerId: customerId).path,
            method: .post,
            body: record
        )
        return try await fetch(endpoint)
    }

    func deleteFollow(id: String) async throws {
        try await fetchVoid(AppEndpoint.Follow.delete(id: id))
    }
}
