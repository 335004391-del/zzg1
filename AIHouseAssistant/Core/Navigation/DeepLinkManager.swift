import Foundation

/// DeepLink 解析器 —— 将外部 URL 转换为类型安全的导航路由
/// 支持：通知点击 / 微信跳转 / 二维码扫描 直接进入指定页面
/// 协议格式：app://customer/1001、app://house/2003、app://match/3001
struct DeepLinkManager {

    /// 解析一个 URL，返回导航路由（无法识别时返回 nil）
    func resolve(_ url: URL) -> DeepLinkRoute? {
        // 校验 Scheme
        guard url.scheme == AppRoute.scheme else {
            AppLogger.error("DeepLink Scheme 不匹配: \(url.absoluteString)", category: .ui)
            return nil
        }
        // host 即路由分类
        guard let hostString = url.host,
              let host = AppRoute.Host(rawValue: hostString) else {
            AppLogger.error("DeepLink Host 不识别: \(url.absoluteString)", category: .ui)
            return nil
        }

        // 路径首段作为资源 ID（如 /1001）
        let id = url.pathComponents.first(where: { $0 != "/" }) ?? ""

        switch host {
        case .customer:
            guard !id.isEmpty else { return DeepLinkRoute(tab: .customer) }
            return DeepLinkRoute(tab: .customer, destination: .customerDetail(customerId: id))

        case .house:
            guard !id.isEmpty else { return DeepLinkRoute(tab: .house) }
            return DeepLinkRoute(tab: .house, destination: .houseDetail(houseId: id))

        case .match:
            guard !id.isEmpty else { return DeepLinkRoute(tab: .ai) }
            return DeepLinkRoute(tab: .ai, destination: .aiReport(matchId: id))

        case .dashboard:
            return DeepLinkRoute(tab: .dashboard)

        case .profile:
            return DeepLinkRoute(tab: .profile)

        case .settings:
            return DeepLinkRoute(tab: .profile, destination: .settings)
        }
    }
}
