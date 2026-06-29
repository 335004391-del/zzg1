import Foundation

/// 房源数据变更广播 —— 解耦跨页面的数据刷新
/// 新增 / 编辑 / 删除后递增版本号，列表与详情页监听后自动刷新
@MainActor
@Observable
final class HouseEvents {

    static let shared = HouseEvents()
    private init() {}

    /// 数据版本号（每次变更递增）
    private(set) var version: Int = 0

    func markChanged() {
        version &+= 1
    }
}
