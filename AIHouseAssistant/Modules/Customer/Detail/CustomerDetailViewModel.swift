import Foundation

/// 客户详情视图模型 —— 加载客户详情 / 跟进记录 / 生成 Mock AI 画像
@MainActor
@Observable
final class CustomerDetailViewModel {

    // MARK: - 状态

    private(set) var customer: Customer?
    private(set) var follows: [FollowRecord] = []
    /// Mock AI 画像要点
    private(set) var aiPoints: [String] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    // MARK: - 依赖

    private let customerId: String
    private var repository: (any CustomerRepositoryProtocol)?

    init(customerId: String) {
        self.customerId = customerId
    }

    // MARK: - 加载

    func onAppear(repository: any CustomerRepositoryProtocol) async {
        self.repository = repository
        if customer == nil { await load() }
    }

    /// 外部变更后刷新
    func reloadAfterExternalChange() async {
        guard repository != nil else { return }
        await load()
    }

    private func load() async {
        guard let repository else { return }
        isLoading = (customer == nil)
        errorMessage = nil
        do {
            let detail = try await repository.detail(id: customerId)
            customer = detail
            aiPoints = Self.makeAIPoints(from: detail)
            // 跟进记录
            let page = PageRequest(page: 1, pageSize: 50)
            follows = try await repository.follows(customerId: customerId, page: page).items
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - 操作

    func toggleFavorite() async {
        guard let repository, let current = customer else { return }
        do {
            customer = try await repository.toggleFavorite(id: current.id)
            CustomerEvents.shared.markChanged()
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
    }

    func delete() async -> Bool {
        guard let repository, let current = customer else { return false }
        do {
            try await repository.delete(id: current.id)
            CustomerEvents.shared.markChanged()
            return true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }

    // MARK: - Mock AI 画像生成（基于客户数据，非真实 AI）

    private static func makeAIPoints(from c: Customer) -> [String] {
        var points: [String] = []
        points.append("预算 \(c.budgetDescription)，购买力\(c.budgetMax >= 500 ? "较强" : "稳定")")

        if c.tags.contains(.subway) || c.subwayRequirement {
            points.append("偏好地铁沿线，看重通勤便利")
        }
        if c.tags.contains(.school) || c.schoolRequirement {
            points.append("关注学区，可能有子女教育需求")
        }
        if c.tags.contains(.investment) {
            points.append("具备投资意向，关注区域升值潜力")
        }
        if c.tags.contains(.retirement) {
            points.append("养老需求，偏好安静宜居环境")
        }
        points.append("购房目的：\(c.housePurpose.displayName)，意向区域 \(c.primaryArea)")

        return points
    }
}
