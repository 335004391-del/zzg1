import Foundation

/// 用户仓储协议 — 定义用户认证与信息操作接口
protocol UserRepositoryProtocol {

    /// 手机号 + 密码登录（成功后 Token 由仓储内部保存）
    func login(phone: String, password: String) async throws -> User

    /// 退出登录（清除 Token 与本地缓存）
    func logout() async throws

    /// 读取本地缓存的当前用户（无需网络）
    func currentUser() -> User?

    /// 从服务器刷新当前用户信息
    func refreshProfile() async throws -> User
}
