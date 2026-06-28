import SwiftUI

/// 应用程序入口
@main
struct AIHouseAssistantApp: App {

    /// 依赖容器（全局单例）
    @StateObject private var container = DependencyContainer.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .preferredColorScheme(nil) // 支持 Dark Mode
        }
    }
}
