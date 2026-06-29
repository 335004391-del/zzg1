import Foundation

/// 房源详情视图模型 —— 加载详情 / 生成 Mock AI 分析
@MainActor
@Observable
final class HouseDetailViewModel {

    // MARK: - 状态

    private(set) var house: House?
    /// Mock AI 分析要点
    private(set) var aiPoints: [String] = []
    /// AI 预估成交速度描述
    private(set) var aiDealSpeed: String = ""
    /// 推荐客户数量（占位）
    private(set) var recommendedCustomerCount: Int = 0
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - 依赖

    private let houseId: String
    private var repository: (any HouseRepositoryProtocol)?

    init(houseId: String) {
        self.houseId = houseId
    }

    // MARK: - 加载

    func onAppear(repository: any HouseRepositoryProtocol) async {
        self.repository = repository
        if house == nil { await load() }
    }

    func reloadAfterExternalChange() async {
        guard repository != nil else { return }
        await load()
    }

    private func load() async {
        guard let repository else { return }
        isLoading = (house == nil)
        errorMessage = nil
        do {
            let detail = try await repository.detail(id: houseId)
            house = detail
            aiPoints = Self.makeAIPoints(from: detail)
            aiDealSpeed = Self.makeDealSpeed(from: detail)
            recommendedCustomerCount = (detail.aiRecommendScore / 8) + 1
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - 操作

    func toggleFavorite() async {
        guard let repository, let current = house else { return }
        do {
            house = try await repository.toggleFavorite(id: current.id)
            HouseEvents.shared.markChanged()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func delete() async -> Bool {
        guard let repository, let current = house else { return false }
        do {
            try await repository.delete(id: current.id)
            HouseEvents.shared.markChanged()
            return true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    // MARK: - Mock AI 分析（基于房源数据，非真实算法）

    private static func makeAIPoints(from h: House) -> [String] {
        var points: [String] = []
        if let distance = h.subwayDistance {
            points.append("距离地铁约 \(distance) 米，通勤便利")
        }
        if h.tags.contains(.school) || h.schoolInfo != nil {
            points.append("学区优质，适合有教育需求的家庭")
        }
        if h.decoration == .fine || h.decoration == .luxury {
            points.append("\(h.decoration.displayName)交付，可拎包入住")
        }
        if h.tags.contains(.park) || h.tags.contains(.scenery) {
            points.append("景观/公园资源稀缺，宜居性强")
        }
        points.append("户型 \(h.layoutDescription)，\(h.areaDescription)，适合\(h.rooms >= 3 ? "改善型" : "刚需型")家庭")
        return points
    }

    private static func makeDealSpeed(from h: House) -> String {
        switch h.aiRecommendScore {
        case 85...: return "预计成交速度：快"
        case 65..<85: return "预计成交速度：较快"
        default: return "预计成交速度：正常"
        }
    }
}
