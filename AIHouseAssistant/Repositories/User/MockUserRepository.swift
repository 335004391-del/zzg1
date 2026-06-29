import Foundation

/// Mock 用户仓储 — 返回本地 MockData 用户信息，用于开发阶段 / Preview
final class MockUserRepository: UserRepositoryProtocol {

    private var cachedUser: User? = MockData.currentUser

    func login(phone: String, password: String) async throws -> User {
        try await simulateDelay()
        // Mock 直接返回预设用户
        cachedUser = MockData.currentUser
        return MockData.currentUser
    }

    func logout() async throws {
        try await simulateDelay()
        cachedUser = nil
    }

    func currentUser() -> User? {
        cachedUser
    }

    func refreshProfile() async throws -> User {
        try await simulateDelay()
        return MockData.currentUser
    }

    private func simulateDelay(_ seconds: Double = 0.3) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
