import Foundation
import SwiftUI

/// 依赖注入容器 — 统一管理所有服务实例
/// 后续可通过替换实现轻松切换 AI 提供商、网络层等
@MainActor
final class DependencyContainer: ObservableObject {

    // MARK: - 单例

    static let shared = DependencyContainer()

    // MARK: - 核心服务

    /// 网络管理器
    let networkManager: NetworkManager

    /// 本地存储
    let storageManager: StorageManager

    // MARK: - 初始化

    private init() {
        self.networkManager = NetworkManager.shared
        self.storageManager = StorageManager.shared
        AppLogger.info("依赖容器初始化完成", category: .general)
    }
}
