import SwiftUI

/// 根视图 —— App 全局入口
/// 结构：RootView → MainTabView（内部各 Tab 自带 NavigationStack）
struct RootView: View {

    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        MainTabView()
            .onOpenURL { url in
                // 处理外部 DeepLink（通知 / 微信 / 二维码）
                NavigationCoordinator.shared.handle(url: url)
            }
    }
}

#Preview {
    RootView()
        .environmentObject(DependencyContainer.shared)
        .environment(NavigationManager.shared)
        .environment(SheetManager.shared)
        .environment(ModalManager.shared)
}
