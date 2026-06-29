import SwiftUI

/// 应用程序入口
@main
struct AIHouseAssistantApp: App {

    /// 依赖容器（全局单例）
    @StateObject private var container = DependencyContainer.shared

    /// 导航协调器（聚合全部导航子系统）
    @State private var coordinator = NavigationCoordinator.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                // 注入导航子系统，供各页面读取
                .environment(coordinator.navigation)
                .environment(coordinator.sheet)
                .environment(coordinator.modal)
                .preferredColorScheme(nil) // 跟随系统，支持 Dark Mode
        }
    }
}
