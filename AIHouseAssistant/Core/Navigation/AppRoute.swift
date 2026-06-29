import Foundation

/// DeepLink 路由协议常量与解析结果模型
/// 支持外部入口（通知 / 微信 / 二维码）直接跳转到指定页面
/// 例如：app://customer/1001  app://house/2003  app://match/3001
enum AppRoute {

    /// 自定义 URL Scheme
    static let scheme = "app"

    /// 路由 Host 定义（即 app://<host>/...）
    enum Host: String {
        case customer   // app://customer/{id}
        case house      // app://house/{id}
        case match      // app://match/{id}
        case dashboard  // app://dashboard
        case profile    // app://profile
        case settings   // app://settings
    }
}

// MARK: - DeepLink 解析结果

/// 一条 DeepLink 解析后的目标 —— 包含目标 Tab 与可选的二级页面
struct DeepLinkRoute: Equatable {

    /// 落点 Tab（必跳）
    let tab: AppTab

    /// 二级页面（可选；nil 表示仅切换到 Tab 根页面）
    let destination: AppDestination?

    init(tab: AppTab, destination: AppDestination? = nil) {
        self.tab         = tab
        self.destination = destination
    }
}
