import SwiftUI

/// 半屏弹层内容定义 —— 统一管理 BottomSheet / Picker / ImageViewer 等
/// 页面禁止自行持有 sheet 状态，必须通过 SheetManager 呈现
enum AppSheet: Identifiable, Hashable {

    /// 筛选器（占位）
    case filter
    /// 选择器（标题占位）
    case picker(title: String)
    /// 图片查看器（半屏）
    case imageViewer(urls: [String], startIndex: Int)

    var id: String {
        switch self {
        case .filter:                      return "filter"
        case .picker(let title):           return "picker-\(title)"
        case .imageViewer(let urls, let i): return "image-\(urls.count)-\(i)"
        }
    }

    /// 弹层标题
    var title: String {
        switch self {
        case .filter:           return "筛选"
        case .picker(let t):    return t
        case .imageViewer:      return "图片预览"
        }
    }
}

/// 半屏弹层管理器 —— 全局唯一的 sheet 呈现状态来源
@MainActor
@Observable
final class SheetManager {

    // MARK: - 单例

    static let shared = SheetManager()
    private init() {}

    // MARK: - 状态

    /// 当前呈现的弹层（nil 表示无）
    var current: AppSheet?

    // MARK: - 操作

    /// 呈现一个半屏弹层
    func present(_ sheet: AppSheet) {
        current = sheet
        AppLogger.debug("呈现 Sheet: \(sheet.id)", category: .ui)
    }

    /// 关闭当前弹层
    func dismiss() {
        guard current != nil else { return }
        current = nil
    }
}
