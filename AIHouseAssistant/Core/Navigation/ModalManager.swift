import SwiftUI

/// 全屏弹层内容定义 —— 统一管理登录 / 图片浏览 / 扫码等 FullScreenCover
/// 页面禁止自行持有 fullScreenCover 状态，必须通过 ModalManager 呈现
enum AppFullScreen: Identifiable, Hashable {

    /// 登录页
    case login
    /// 全屏图片浏览器
    case imageBrowser(urls: [String], startIndex: Int)
    /// 扫码
    case scanner

    var id: String {
        switch self {
        case .login:                        return "login"
        case .imageBrowser(let urls, let i): return "browser-\(urls.count)-\(i)"
        case .scanner:                      return "scanner"
        }
    }

    /// 标题
    var title: String {
        switch self {
        case .login:        return "登录"
        case .imageBrowser: return "图片浏览"
        case .scanner:      return "扫一扫"
        }
    }
}

/// 全屏弹层管理器 —— 全局唯一的 fullScreenCover 呈现状态来源
@MainActor
@Observable
final class ModalManager {

    // MARK: - 单例

    static let shared = ModalManager()
    private init() {}

    // MARK: - 状态

    /// 当前呈现的全屏弹层（nil 表示无）
    var current: AppFullScreen?

    // MARK: - 操作

    /// 呈现一个全屏弹层
    func present(_ modal: AppFullScreen) {
        current = modal
        AppLogger.debug("呈现 FullScreen: \(modal.id)", category: .ui)
    }

    /// 关闭当前全屏弹层
    func dismiss() {
        guard current != nil else { return }
        current = nil
    }
}
