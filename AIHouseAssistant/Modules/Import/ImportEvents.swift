import Foundation

/// 导入数据变更广播 —— 导入完成后通知首页刷新历史
@MainActor
@Observable
final class ImportEvents {

    static let shared = ImportEvents()
    private init() {}

    private(set) var version: Int = 0

    func markChanged() { version &+= 1 }
}
