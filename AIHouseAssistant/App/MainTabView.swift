import SwiftUI

/// 主 TabBar 容器 —— App 的导航骨架
/// 每个 Tab 拥有独立 NavigationStack；所有跳转由 NavigationManager 驱动
/// 半屏 / 全屏弹层由 Sheet / Modal 管理器统一在此挂载
struct MainTabView: View {

    // MARK: - 依赖（从环境注入的导航子系统）

    @Environment(NavigationManager.self) private var navigation
    @Environment(SheetManager.self)      private var sheetManager
    @Environment(ModalManager.self)      private var modalManager

    /// 视图工厂（无状态，可直接持有）
    private let router = AppRouter()

    var body: some View {
        // @Bindable 用于把 @Observable 属性转为 Binding
        @Bindable var navigation   = navigation
        @Bindable var sheetManager = sheetManager
        @Bindable var modalManager = modalManager

        TabView(selection: tabSelection) {
            ForEach(AppTab.allCases) { tab in
                tabStack(for: tab)
                    .tabItem {
                        Label(
                            tab.title,
                            systemImage: navigation.selectedTab == tab ? tab.selectedIcon : tab.icon
                        )
                    }
                    .tag(tab)
            }
        }
        .tint(AppColor.primary)
        // 半屏弹层统一挂载
        .sheet(item: $sheetManager.current) { sheet in
            NavigationStack {
                router.sheetView(for: sheet)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        // 全屏弹层统一挂载
        .fullScreenCover(item: $modalManager.current) { modal in
            NavigationStack {
                router.fullScreenView(for: modal)
            }
        }
    }

    // MARK: - 子视图

    /// 单个 Tab 的导航栈
    private func tabStack(for tab: AppTab) -> some View {
        NavigationStack(path: navigation.pathBinding(for: tab)) {
            router.view(for: tab.rootDestination)
                .navigationDestination(for: AppDestination.self) { destination in
                    router.view(for: destination)
                }
        }
    }

    /// Tab 选择绑定 —— 重复点击当前 Tab 时回到根页面
    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { navigation.selectedTab },
            set: { navigation.selectTab($0) }
        )
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(NavigationManager.shared)
        .environment(SheetManager.shared)
        .environment(ModalManager.shared)
}
