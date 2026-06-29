import Foundation
import Security

/// Token 管理器 — 负责 JWT 访问令牌与刷新令牌的 Keychain 安全存储
final class TokenManager: @unchecked Sendable {

    // MARK: - 单例

    static let shared = TokenManager()
    private init() {}

    // MARK: - Keychain Key 常量

    private enum Key {
        static let accessToken  = "com.aihouseassistant.token.access"
        static let refreshToken = "com.aihouseassistant.token.refresh"
    }

    // MARK: - 存储

    /// 保存访问令牌到 Keychain
    func saveAccessToken(_ token: String) {
        save(value: token, forKey: Key.accessToken)
        AppLogger.debug("访问令牌已保存", category: .network)
    }

    /// 保存刷新令牌到 Keychain
    func saveRefreshToken(_ token: String) {
        save(value: token, forKey: Key.refreshToken)
    }

    // MARK: - 读取

    /// 当前访问令牌（nil 表示未登录）
    var accessToken: String? { load(forKey: Key.accessToken) }

    /// 当前刷新令牌
    var refreshToken: String? { load(forKey: Key.refreshToken) }

    /// 是否已登录
    var isLoggedIn: Bool { accessToken != nil }

    // MARK: - 清除

    /// 删除所有令牌（退出登录时调用）
    func clearAll() {
        delete(forKey: Key.accessToken)
        delete(forKey: Key.refreshToken)
        AppLogger.info("所有 Token 已清除", category: .network)
    }

    // MARK: - Keychain 底层操作

    private func save(value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        let attrs: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key as CFString,
            kSecValueData:   data,
        ]
        SecItemDelete(attrs as CFDictionary)
        let status = SecItemAdd(attrs as CFDictionary, nil)
        if status != errSecSuccess {
            AppLogger.error("Keychain 写入失败: \(status)", category: .network)
        }
    }

    private func load(forKey key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key as CFString,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var item: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(forKey key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key as CFString,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
