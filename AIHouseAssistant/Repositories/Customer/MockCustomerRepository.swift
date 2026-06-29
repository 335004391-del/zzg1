import Foundation

/// Mock 客户仓储 —— 内存态实现，承载 100 条随机客户数据
/// 支持搜索 / 筛选 / 排序 / 分页 / 收藏 / 增删改，模拟真实后端行为
/// 使用 actor 保证可变状态的并发安全
actor MockCustomerRepository: CustomerRepositoryProtocol {

    // MARK: - 内存数据

    /// 客户存储（启动时生成 100 条）
    private var store: [Customer] = MockCustomerFactory.generate(count: 100)
    /// 跟进记录缓存（按客户 ID）
    private var followStore: [String: [FollowRecord]] = [:]

    // MARK: - 查询（搜索 + 筛选 + 排序 + 分页）

    func query(_ query: CustomerQuery) async throws -> PageResponse<Customer> {
        try await simulateDelay()

        var result = store

        // 1) 仅看收藏
        if query.favoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        // 2) 关键词搜索（姓名 / 电话 / 微信 / 公司）
        let kw = query.keyword.trimmingCharacters(in: .whitespaces)
        if !kw.isEmpty {
            result = result.filter { c in
                c.name.contains(kw)
                || c.phone.contains(kw)
                || (c.wechat?.contains(kw) ?? false)
                || (c.company?.contains(kw) ?? false)
            }
        }

        // 3) 筛选
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

    // MARK: - 筛选逻辑

    private func applyFilter(_ filter: CustomerFilter, to list: [Customer]) -> [Customer] {
        guard !filter.isEmpty else { return list }
        return list.filter { c in
            // 状态
            if !filter.statuses.isEmpty, !filter.statuses.contains(c.status) { return false }
            // 标签（任一命中）
            if !filter.tags.isEmpty, filter.tags.isDisjoint(with: Set(c.tags)) { return false }
            // 区域（任一命中）
            if !filter.areas.isEmpty, filter.areas.isDisjoint(with: Set(c.preferredArea)) { return false }
            // 预算区间（与客户预算区间有交集）
            if let minB = filter.budgetMin, c.budgetMax < minB { return false }
            if let maxB = filter.budgetMax, c.budgetMin > maxB { return false }
            // 成交概率
            if let minP = filter.minDealProbability, c.dealProbability < minP { return false }
            // 最后联系时间
            if let days = filter.lastContactWithinDays {
                guard let last = c.lastContactAt else { return false }
                let diff = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? Int.max
                if diff > days { return false }
            }
            return true
        }
    }

    // MARK: - 排序逻辑

    private func applySort(_ sort: CustomerSortOption, to list: [Customer]) -> [Customer] {
        switch sort {
        case .newest:
            return list.sorted { $0.createdAt > $1.createdAt }
        case .recentContact:
            return list.sorted {
                ($0.lastContactAt ?? .distantPast) > ($1.lastContactAt ?? .distantPast)
            }
        case .budgetHigh:
            return list.sorted { $0.budgetMax > $1.budgetMax }
        case .dealProbability:
            return list.sorted { $0.dealProbability > $1.dealProbability }
        case .nameAZ:
            return list.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        }
    }

    // MARK: - 详情

    func detail(id: String) async throws -> Customer {
        try await simulateDelay(0.3)
        guard let customer = store.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return customer
    }

    // MARK: - 收藏

    func toggleFavorite(id: String) async throws -> Customer {
        guard let index = store.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        store[index].isFavorite.toggle()
        return store[index]
    }

    // MARK: - 写操作

    func create(_ customer: Customer) async throws -> Customer {
        try await simulateDelay(0.4)
        var created       = customer
        created.id        = UUID().uuidString
        created.createdAt = Date()
        created.updatedAt = Date()
        if created.customerCode.isEmpty {
            created.customerCode = String(format: "C2024%04d", store.count + 1)
        }
        store.insert(created, at: 0)
        return created
    }

    func update(_ customer: Customer) async throws -> Customer {
        try await simulateDelay(0.4)
        guard let index = store.firstIndex(where: { $0.id == customer.id }) else {
            throw APIError.notFound
        }
        var updated       = customer
        updated.updatedAt = Date()
        store[index]      = updated
        return updated
    }

    func delete(id: String) async throws {
        try await simulateDelay(0.3)
        store.removeAll { $0.id == id }
        followStore[id] = nil
    }

    // MARK: - 跟进记录

    func follows(customerId: String, page: PageRequest) async throws -> PageResponse<FollowRecord> {
        try await simulateDelay(0.3)
        let records = followStore[customerId] ?? generateFollows(for: customerId)
        followStore[customerId] = records
        return PageResponse(
            items:    records,
            total:    records.count,
            page:     1,
            pageSize: page.pageSize,
            hasMore:  false
        )
    }

    func createFollow(_ record: FollowRecord, customerId: String) async throws -> FollowRecord {
        try await simulateDelay(0.3)
        var created        = record
        created.id         = UUID().uuidString
        created.customerId = customerId
        followStore[customerId, default: []].insert(created, at: 0)
        return created
    }

    func deleteFollow(id: String) async throws {
        try await simulateDelay(0.2)
        for key in followStore.keys {
            followStore[key]?.removeAll { $0.id == id }
        }
    }

    // MARK: - 兼容旧接口

    func list(page: PageRequest) async throws -> PageResponse<Customer> {
        try await query(CustomerQuery(keyword: page.keyword ?? "",
                                      page: page.page, pageSize: page.pageSize))
    }

    // MARK: - 工具

    /// 为客户生成 0~3 条 Mock 跟进记录
    private func generateFollows(for customerId: String) -> [FollowRecord] {
        let count = Int(abs(customerId.hashValue) % 4) // 0~3
        guard count > 0 else { return [] }
        let types: [FollowType] = [.phone, .wechat, .visit, .houseView, .negotiate]
        let contents = [
            "电话沟通，客户对当前房源较满意，预算可接受。",
            "微信发送了 3 套房源资料，客户表示周末有空看房。",
            "带看碧桂园天玺，客户对户型和采光很满意。",
            "客户对价格有顾虑，已申请折扣方案。",
            "上门拜访，进一步了解客户家庭购房需求。",
        ]
        return (0..<count).map { i in
            FollowRecord(
                id:               "\(customerId)-f\(i)",
                customerId:       customerId,
                salesId:          "u-001",
                salesName:        "张经理",
                followType:       types[i % types.count],
                content:          contents[i % contents.count],
                durationMinutes:  Int.random(in: 5...45),
                visitedHouseIds:  [],
                customerFeedback: i == 0 ? "意向较强，可重点跟进" : nil,
                nextFollowDate:   Calendar.current.date(byAdding: .day, value: 3, to: Date()),
                nextFollowPlan:   "继续推荐合适房源",
                createdAt:        Calendar.current.date(byAdding: .day, value: -(i * 3 + 1), to: Date()) ?? Date()
            )
        }
    }

    private func simulateDelay(_ seconds: Double = 0.5) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
