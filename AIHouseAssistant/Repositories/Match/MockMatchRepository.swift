import Foundation

/// Mock 匹配仓储 —— 内存态实现，承载 100 客户 / 500 房源，调用 MatchEngine 计算
/// 仓储只负责数据存取与调度引擎，算法全部在 MatchEngine 中
actor MockMatchRepository: MatchRepositoryProtocol {

    // MARK: - 内存数据

    private let customerStore: [Customer] = MockCustomerFactory.generate(count: 100)
    private let houseStore: [House] = MockHouseFactory.generate(count: 500)
    /// 收藏键集合（customerId-houseId）
    private var favorites: Set<String> = []

    /// 匹配引擎
    private let engine = MatchEngine()

    // MARK: - 客户

    func customers() async throws -> [Customer] {
        try await simulateDelay(0.3)
        return customerStore
    }

    // MARK: - 推荐

    func recommend(customerId: String, options: MatchOptions) async throws -> [MatchRecommendation] {
        try await simulateDelay(0.8)  // 模拟匹配计算耗时
        guard let customer = customerStore.first(where: { $0.id == customerId }) else {
            throw APIError.notFound
        }
        return engine.match(customer: customer, houses: houseStore,
                            favorites: favorites, options: options)
    }

    // MARK: - 单项评估（详情）

    func recommendation(customerId: String, houseId: String) async throws -> MatchRecommendation? {
        try await simulateDelay(0.3)
        guard let customer = customerStore.first(where: { $0.id == customerId }),
              let house = houseStore.first(where: { $0.id == houseId }) else {
            return nil
        }
        let key = "\(customerId)-\(houseId)"
        return engine.evaluate(customer: customer, house: house,
                              isFavorite: favorites.contains(key))
    }

    // MARK: - 收藏

    func toggleFavorite(customerId: String, houseId: String) async throws -> MatchRecommendation {
        let key = "\(customerId)-\(houseId)"
        if favorites.contains(key) { favorites.remove(key) } else { favorites.insert(key) }

        guard let customer = customerStore.first(where: { $0.id == customerId }),
              let house = houseStore.first(where: { $0.id == houseId }) else {
            throw APIError.notFound
        }
        return engine.evaluate(customer: customer, house: house,
                              isFavorite: favorites.contains(key))
    }

    // MARK: - 工具

    private func simulateDelay(_ seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
