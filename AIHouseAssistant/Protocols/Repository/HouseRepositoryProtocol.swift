import Foundation

/// 房源仓储协议 — 定义房源相关所有数据操作接口
protocol HouseRepositoryProtocol {

    /// 获取房源列表（分页 + 搜索）
    func list(page: PageRequest) async throws -> PageResponse<House>

    /// 获取房源详情
    func detail(id: String) async throws -> House

    /// 创建房源
    func create(_ house: House) async throws -> House

    /// 更新房源信息
    func update(_ house: House) async throws -> House

    /// 删除房源
    func delete(id: String) async throws
}
