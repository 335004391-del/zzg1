import SwiftUI

/// 导航管理器 —— 整个 App 唯一的导航状态中枢
/// 所有页面跳转必须经由此处，严禁 View 自行持有 NavigationPath
/// 每个 Tab 维护一条独立的导航栈，互不干扰
@MainActor
@Observable
final class NavigationManager {

    // MARK: - 单例

    static let shared = NavigationManager()
    private init() {}

    // MARK: - 状态

    /// 当前选中的 Tab
    var selectedTab: AppTab = .dashboard

    /// 每个 Tab 独立的导航栈路径（key 为 Tab）
    private var paths: [AppTab: [AppDestination]] = [:]

    // MARK: - 路径访问（供 NavigationStack 绑定）

    /// 获取指定 Tab 的栈路径绑定
    func pathBinding(for tab: AppTab) -> Binding<[AppDestination]> {
        Binding(
            get: { [weak self] in self?.paths[tab] ?? [] },
            set: { [weak self] newValue in self?.paths[tab] = newValue }
        )
    }

    /// 当前 Tab 栈深度（0 表示位于根页面）
    var currentDepth: Int { paths[selectedTab]?.count ?? 0 }

    // MARK: - Tab 切换

    /// 切换 Tab；若点击已选中的 Tab，则回到该 Tab 根页面
    func selectTab(_ tab: AppTab) {
        if selectedTab == tab {
            popToRoot(in: tab)
        } else {
            selectedTab = tab
        }
    }

    // MARK: - 栈操作（默认作用于当前 Tab）

    /// 入栈一个页面
    func push(_ destination: AppDestination) {
        push(destination, in: selectedTab)
    }

    /// 在指定 Tab 入栈一个页面
    func push(_ destination: AppDestination, in tab: AppTab) {
        paths[tab, default: []].append(destination)
        AppLogger.debug("Push → \(destination.title)（Tab: \(tab.title)）", category: .ui)
    }

    /// 返回上一页
    func pop() {
        guard !(paths[selectedTab]?.isEmpty ?? true) else { return }
        paths[selectedTab]?.removeLast()
    }

    /// 返回当前 Tab 根页面
    func popToRoot() {
        popToRoot(in: selectedTab)
    }

    /// 返回指定 Tab 根页面
    func popToRoot(in tab: AppTab) {
        guard !(paths[tab]?.isEmpty ?? true) else { return }
        paths[tab]?.removeAll()
    }

    /// 替换栈顶页面（先弹出再压入，避免返回到原页面）
    func replace(with destination: AppDestination) {
        if !(paths[selectedTab]?.isEmpty ?? true) {
            paths[selectedTab]?.removeLast()
        }
        paths[selectedTab, default: []].append(destination)
    }

    /// 重置整个导航系统（退出登录等场景调用）
    func reset() {
        paths.removeAll()
        selectedTab = .dashboard
        AppLogger.info("导航系统已重置", category: .ui)
    }

    // MARK: - 弹层转发（统一入口，内部委托给 Sheet / Modal 管理器）

    /// 呈现半屏弹层
    func openSheet(_ sheet: AppSheet) {
        SheetManager.shared.present(sheet)
    }

    /// 关闭半屏弹层
    func dismissSheet() {
        SheetManager.shared.dismiss()
    }

    /// 呈现全屏弹层
    func openFullScreen(_ modal: AppFullScreen) {
        ModalManager.shared.present(modal)
    }

    /// 关闭全屏弹层
    func dismissFullScreen() {
        ModalManager.shared.dismiss()
    }

    // MARK: - DeepLink 应用

    /// 应用一条 DeepLink 解析结果：切换 Tab 并按需压栈
    func apply(_ route: DeepLinkRoute) {
        selectedTab = route.tab
        popToRoot(in: route.tab)
        if let destination = route.destination {
            push(destination, in: route.tab)
        }
        AppLogger.info("应用 DeepLink → Tab: \(route.tab.title)", category: .ui)
    }
}
