import Foundation
import SwiftUI

/// 依赖注入容器 — 统一管理所有服务、仓储实例
/// Debug 环境自动注入 Mock 仓储，Release 环境注入真实 API 仓储
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - 单例

    static let shared = DependencyContainer()

    // MARK: - 核心服务

    /// 本地存储
    let storageManager: StorageManager

    /// Token 管理
    let tokenManager: TokenManager

    /// 网络状态监听
    let networkMonitor: NetworkMonitor

    // MARK: - 仓储层（面向协议，方便 Mock 替换）

    /// 客户仓储
    let customerRepository: any CustomerRepositoryProtocol

    /// 房源仓储
    let houseRepository: any HouseRepositoryProtocol

    /// 匹配仓储
    let matchRepository: any MatchRepositoryProtocol

    /// 仪表盘仓储
    let dashboardRepository: any DashboardRepositoryProtocol

    /// 用户仓储
    let userRepository: any UserRepositoryProtocol

    // MARK: - 初始化

    private init() {
        self.storageManager  = StorageManager.shared
        self.tokenManager    = TokenManager.shared
        self.networkMonitor  = NetworkMonitor.shared

        // Debug 环境使用 Mock 仓储（无需后端服务即可开发）
        #if DEBUG
        self.customerRepository  = MockCustomerRepository()
        self.houseRepository     = MockHouseRepository()
        self.matchRepository     = MockMatchRepository()
        self.dashboardRepository = MockDashboardRepository()
        self.userRepository      = MockUserRepository()
        #else
        let api = APIClient.shared
        self.customerRepository  = CustomerRepository(apiClient: api)
        self.houseRepository     = HouseRepository(apiClient: api)
        self.matchRepository     = MatchRepository(apiClient: api)
        self.dashboardRepository = DashboardRepository(apiClient: api)
        self.userRepository      = UserRepository(apiClient: api)
        #endif

        AppLogger.info("依赖容器初始化完成（\(isDebug ? "Debug/Mock" : "Release/API")）", category: .general)
    }

    private var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
