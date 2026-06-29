import SwiftUI

/// 路由视图工厂 —— 负责把「目的地」翻译为「具体页面」
/// 将「导航状态（NavigationManager）」与「视图构建」彻底解耦
/// 当前阶段所有页面均为 Coming Soon 占位，后续任务逐步替换
struct AppRouter {

    // MARK: - 栈内页面

    /// 根据目的地构建页面视图
    @ViewBuilder
    func view(for destination: AppDestination) -> some View {
        switch destination {
        case .dashboard:
            DashboardView()

        case .customerList:
            ComingSoonView(title: "客户列表", icon: "person.2.fill")

        case .customerDetail(let customerId):
            ComingSoonView(title: "客户详情", icon: "person.text.rectangle.fill",
                           subtitle: "客户 ID：\(customerId)")

        case .followRecord(let customerId):
            ComingSoonView(title: "跟进记录", icon: "list.bullet.clipboard.fill",
                           subtitle: "客户 ID：\(customerId)")

        case .houseList:
            ComingSoonView(title: "房源列表", icon: "building.2.fill")

        case .houseDetail(let houseId):
            ComingSoonView(title: "房源详情", icon: "house.lodge.fill",
                           subtitle: "房源 ID：\(houseId)")

        case .match(let customerId):
            ComingSoonView(title: "智能匹配", icon: "sparkles",
                           subtitle: customerId.isEmpty ? nil : "客户 ID：\(customerId)")

        case .aiProfile(let customerId):
            ComingSoonView(title: "AI 画像", icon: "brain.head.profile.fill",
                           subtitle: "客户 ID：\(customerId)")

        case .aiReport(let matchId):
            ComingSoonView(title: "AI 匹配报告", icon: "doc.text.magnifyingglass",
                           subtitle: "匹配 ID：\(matchId)")

        case .settings:
            ComingSoonView(title: "设置", icon: "gearshape.fill")

        case .profile:
            ComingSoonView(title: "我的", icon: "person.crop.circle.fill")

        case .login:
            ComingSoonView(title: "登录", icon: "person.badge.key.fill")

        case .splash:
            ComingSoonView(title: "启动", icon: "sparkle")
        }
    }

    // MARK: - 半屏弹层

    /// 根据弹层类型构建半屏内容
    @ViewBuilder
    func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .filter:
            ComingSoonView(title: "筛选", icon: "line.3.horizontal.decrease.circle.fill")
        case .picker(let title):
            ComingSoonView(title: title, icon: "slider.horizontal.3")
        case .imageViewer(let urls, let index):
            ComingSoonView(title: "图片预览", icon: "photo.fill",
                           subtitle: "\(index + 1) / \(urls.count)")
        }
    }

    // MARK: - 全屏弹层

    /// 根据弹层类型构建全屏内容
    @ViewBuilder
    func fullScreenView(for modal: AppFullScreen) -> some View {
        switch modal {
        case .login:
            ComingSoonView(title: "登录", icon: "person.badge.key.fill", showsCloseHint: true)
        case .imageBrowser(let urls, let index):
            ComingSoonView(title: "图片浏览", icon: "photo.stack.fill",
                           subtitle: "\(index + 1) / \(urls.count)", showsCloseHint: true)
        case .scanner:
            ComingSoonView(title: "扫一扫", icon: "qrcode.viewfinder", showsCloseHint: true)
        }
    }
}
