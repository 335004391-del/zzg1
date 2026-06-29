import Foundation

/// 客户仓储协议 — 定义客户与跟进记录的所有数据操作接口
protocol CustomerRepositoryProtocol {

    // MARK: - 客户 CRUD

    /// 获取客户列表（分页 + 搜索）
    func list(page: PageRequest) async throws -> PageResponse<Customer>

    /// 获取客户详情
    func detail(id: String) async throws -> Customer

    /// 创建客户
    func create(_ customer: Customer) async throws -> Customer

    /// 更新客户信息
    func update(_ customer: Customer) async throws -> Customer

    /// 删除客户
    func delete(id: String) async throws

    // MARK: - 跟进记录

    /// 获取客户跟进记录（分页）
    func follows(customerId: String, page: PageRequest) async throws -> PageResponse<FollowRecord>

    /// 创建跟进记录
    func createFollow(_ record: FollowRecord, customerId: String) async throws -> FollowRecord

    /// 删除跟进记录
    func deleteFollow(id: String) async throws
}
