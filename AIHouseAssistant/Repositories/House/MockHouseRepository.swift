import Foundation

/// Mock 房源仓储 —— 内存态实现，承载 200 套随机房源数据
/// 支持搜索 / 高级筛选 / 排序 / 分页 / 收藏 / 增删改，模拟真实后端
/// 使用 actor 保证可变状态并发安全
actor MockHouseRepository: HouseRepositoryProtocol {

    // MARK: - 内存数据

    private var store: [House] = MockHouseFactory.generate(count: 200)

    // MARK: - 查询

    func query(_ query: HouseQuery) async throws -> PageResponse<House> {
        try await simulateDelay()

        var result = store

        // 1) 仅看收藏
        if query.favoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // 2) 关键词搜索（小区 / 标题 / 地址 / 编号）
        let kw = query.keyword.trimmingCharacters(in: .whitespaces)
        if !kw.isEmpty {
            result = result.filter { h in
                h.community.contains(kw) || h.title.contains(kw)
                || h.address.contains(kw) || h.houseCode.contains(kw)
            }
        }

        // 3) 高级筛选
        result = applyFilter(query.filter, to: result)

        // 4) 排序
        result = applySort(query.sort, to: result)

        // 5) 分页
        let total = result.count
        let start = (query.page - 1) * query.pageSize
        let end   = min(start + query.pageSize, total)
        let paged = start < total ? Array(result[start..<end]) : []

        return PageResponse(
            items:    paged,
            total:    total,
            page:     query.page,
            pageSize: query.pageSize,
            hasMore:  end < total
        )
    }

    // MARK: - 筛选

    private func applyFilter(_ filter: HouseFilter, to list: [House]) -> [House] {
        guard !filter.isEmpty else { return list }
        return list.filter { h in
            if !filter.cities.isEmpty, !filter.cities.contains(h.city) { return false }
            if !filter.districts.isEmpty, !filter.districts.contains(h.district) { return false }
            if let minP = filter.priceMin, h.price < minP { return false }
            if let maxP = filter.priceMax, h.price > maxP { return false }
            if let minA = filter.areaMin, h.area < minA { return false }
            if let maxA = filter.areaMax, h.area > maxA { return false }
            if !filter.rooms.isEmpty, !filter.rooms.contains(h.rooms) { return false }
            if !filter.floors.isEmpty, !filter.floors.contains(h.floorCategory) { return false }
            if !filter.decorations.isEmpty, !filter.decorations.contains(h.decoration) { return false }
            if !filter.orientations.isEmpty, !filter.orientations.contains(h.orientation) { return false }
            if !filter.propertyTypes.isEmpty, !filter.propertyTypes.contains(h.propertyType) { return false }
            if !filter.tags.isEmpty, filter.tags.isDisjoint(with: Set(h.tags)) { return false }
            return true
        }
    }

    // MARK: - 排序

    private func applySort(_ sort: HouseSortOption, to list: [House]) -> [House] {
        switch sort {
        case .newest:      return list.sorted { $0.createdAt > $1.createdAt }
        case .priceAsc:    return list.sorted { $0.price < $1.price }
        case .priceDesc:   return list.sorted { $0.price > $1.price }
        case .areaDesc:    return list.sorted { $0.area > $1.area }
        case .areaAsc:     return list.sorted { $0.area < $1.area }
        case .updated:     return list.sorted { $0.updatedAt > $1.updatedAt }
        case .aiRecommend: return list.sorted { $0.aiRecommendScore > $1.aiRecommendScore }
        }
    }

    // MARK: - 详情

    func detail(id: String) async throws -> House {
        try await simulateDelay(0.3)
        guard let house = store.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return house
    }

    // MARK: - 收藏

    func toggleFavorite(id: String) async throws -> House {
        guard let index = store.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        store[index].isFavorite.toggle()
        return store[index]
    }

    // MARK: - 写操作

    func create(_ house: House) async throws -> House {
        try await simulateDelay(0.4)
        var created       = house
        created.id        = UUID().uuidString
        created.createdAt = Date()
        created.updatedAt = Date()
        if created.houseCode.isEmpty {
            created.houseCode = String(format: "H2024%04d", store.count + 1)
        }
        store.insert(created, at: 0)
        return created
    }

    func update(_ house: House) async throws -> House {
        try await simulateDelay(0.4)
        guard let index = store.firstIndex(where: { $0.id == house.id }) else {
            throw APIError.notFound
        }
        var updated       = house
        updated.updatedAt = Date()
        store[index]      = updated
        return updated
    }

    func delete(id: String) async throws {
        try await simulateDelay(0.3)
        store.removeAll { $0.id == id }
    }

    // MARK: - 兼容旧接口

    func list(page: PageRequest) async throws -> PageResponse<House> {
        try await query(HouseQuery(keyword: page.keyword ?? "",
                                   page: page.page, pageSize: page.pageSize))
    }

    // MARK: - 工具

    private func simulateDelay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
