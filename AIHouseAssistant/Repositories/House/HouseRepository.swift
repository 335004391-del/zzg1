import Foundation

/// 房源仓储 — 通过 APIClient 执行所有房源数据网络请求
final class HouseRepository: HouseRepositoryProtocol, BaseRepository {

    // MARK: - 依赖

    let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    // MARK: - 房源列表与详情

    func list(page: PageRequest) async throws -> PageResponse<House> {
        try await fetch(AppEndpoint.House.list(page))
    }

    func detail(id: String) async throws -> House {
        try await fetch(AppEndpoint.House.detail(id: id))
    }

    // MARK: - 房源写操作

    func create(_ house: House) async throws -> House {
        let endpoint = BodyEndpoint(
            path: AppEndpoint.House.create.path,
            method: .post,
            body: house
        )
        return try await fetch(endpoint)
    }

    func update(_ house: House) async throws -> House {
        let endpoint = BodyEndpoint(
            path: AppEndpoint.House.update(id: house.id).path,
            method: .put,
            body: house
        )
        return try await fetch(endpoint)
    }

    func delete(id: String) async throws {
        try await fetchVoid(AppEndpoint.House.delete(id: id))
    }
}
