import Foundation

/// 首页视图模型 —— 承载全部首页业务逻辑，View 不得直接持有数据加载逻辑
/// 数据来源：DashboardRepository（Debug 环境自动为 Mock）
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: - 对外状态（只读）

    /// 首页聚合数据
    private(set) var overview: DashboardOverview?
    /// 是否首屏加载中（已有数据时不再展示整页 Loading）
    private(set) var isLoading = false
    /// 错误信息（nil 表示无错误）
    private(set) var errorMessage: String?

    // MARK: - 依赖

    private var repository: (any DashboardRepositoryProtocol)?
    private var hasLoaded = false

    // MARK: - 派生展示数据（业务逻辑集中在 ViewModel）

    /// 问候语（依当前时段动态变化）
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "早上好"
        case 12..<14: return "中午好"
        case 14..<18: return "下午好"
        default:      return "晚上好"
        }
    }

    /// 当前时间（HH:mm）
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    /// 今天日期（如 "2026年6月29日 星期一"）
    var todayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 EEEE"
        return formatter.string(from: Date())
    }

    /// 完整问候（如 "早上好，张经理"）
    var greetingTitle: String {
        let name = overview?.userName ?? "您好"
        return "\(greeting)，\(name)"
    }

    // MARK: - 生命周期

    /// 首次出现时加载（重复出现不重复请求）
    func onAppear(repository: any DashboardRepositoryProtocol) async {
        self.repository = repository
        guard !hasLoaded else { return }
        await load()
    }

    /// 下拉刷新
    func refresh() async {
        await load()
    }

    // MARK: - 数据加载

    private func load() async {
        guard let repository else { return }
        // 已有数据时静默刷新，不闪烁整页 Loading
        isLoading = (overview == nil)
        errorMessage = nil
        do {
            overview = try await repository.overview()
            hasLoaded = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription
                ?? error.localizedDescription
            AppLogger.error("首页数据加载失败", category: .ui, error: error)
        }
        isLoading = false
    }
}
