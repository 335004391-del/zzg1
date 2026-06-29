import Foundation

/// 用户仓储 — 负责登录 / 登出 / 用户信息的网络请求与本地缓存
final class UserRepository: UserRepositoryProtocol, BaseRepository {

    // MARK: - 依赖

    let apiClient:    APIClient
    let tokenManager: TokenManager
    let storage:      StorageManager

    init(
        apiClient:    APIClient    = .shared,
        tokenManager: TokenManager = .shared,
        storage:      StorageManager = .shared
    ) {
        self.apiClient    = apiClient
        self.tokenManager = tokenManager
        self.storage      = storage
    }

    // MARK: - 认证

    func login(phone: String, password: String) async throws -> User {
        let response: LoginResponse = try await fetch(
            AppEndpoint.Auth.login(phone: phone, password: password)
        )
        // 保存 Token 到 Keychain
        tokenManager.saveAccessToken(response.accessToken)
        tokenManager.saveRefreshToken(response.refreshToken)
        // 缓存用户信息到本地
        storage.save(response.user, forKey: .currentUser)
        AppLogger.info("用户登录成功: \(response.user.name)", category: .network)
        return response.user
    }

    func logout() async throws {
        try await fetchVoid(AppEndpoint.Auth.logout)
        tokenManager.clearAll()
        storage.remove(forKey: .currentUser)
        AppLogger.info("用户已退出登录", category: .network)
    }

    // MARK: - 用户信息

    func currentUser() -> User? {
        storage.load(forKey: .currentUser)
    }

    func refreshProfile() async throws -> User {
        let user: User = try await fetch(MeEndpoint())
        storage.save(user, forKey: .currentUser)
        return user
    }
}

// MARK: - 私有 DTO

/// 登录响应：包含 Token 对与用户信息
private struct LoginResponse: Decodable {
    let accessToken:  String
    let refreshToken: String
    let user:         User
}

/// 获取当前用户信息端点
private struct MeEndpoint: APIEndpoint {
    var path:   String     { "/api/v1/users/me" }
    var method: HTTPMethod { .get }
}
