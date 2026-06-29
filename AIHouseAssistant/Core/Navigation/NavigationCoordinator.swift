import SwiftUI

/// 导航协调器 —— 顶层入口，统一聚合各导航子系统
/// 对外提供「单一调用面」：跳转、弹层、DeepLink 一站式处理
/// 内部组合：NavigationManager / SheetManager / ModalManager / DeepLinkManager / AppRouter
@MainActor
@Observable
final class NavigationCoordinator {

    // MARK: - 单例

    static let shared = NavigationCoordinator()

    // MARK: - 子系统

    /// 栈与 Tab 导航
    let navigation: NavigationManager
    /// 半屏弹层
    let sheet: SheetManager
    /// 全屏弹层
    let modal: ModalManager
    /// 视图工厂（无状态）
    let router: AppRouter
    /// DeepLink 解析器（无状态）
    private let deepLink: DeepLinkManager

    private init() {
        self.navigation = NavigationManager.shared
        self.sheet      = SheetManager.shared
        self.modal      = ModalManager.shared
        self.router     = AppRouter()
        self.deepLink   = DeepLinkManager()
    }

    // MARK: - DeepLink 入口

    /// 处理外部 URL（通知 / 微信 / 二维码），成功则跳转
    @discardableResult
    func handle(url: URL) -> Bool {
        guard let route = deepLink.resolve(url) else { return false }
        navigation.apply(route)
        return true
    }

    // MARK: - 全局重置

    /// 退出登录等场景：清空所有导航与弹层状态
    func resetAll() {
        navigation.reset()
        sheet.dismiss()
        modal.dismiss()
    }
}
