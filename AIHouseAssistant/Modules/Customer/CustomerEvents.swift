import Foundation

/// 客户数据变更广播 —— 解耦跨页面的数据刷新
/// 新增 / 编辑 / 删除后递增版本号，列表与详情页监听后自动刷新
@MainActor
@Observable
final class CustomerEvents {

    static let shared = CustomerEvents()
    private init() {}

    /// 数据版本号（每次变更递增）
    private(set) var version: Int = 0

    /// 标记数据已变更
    func markChanged() {
        version &+= 1
    }
}
