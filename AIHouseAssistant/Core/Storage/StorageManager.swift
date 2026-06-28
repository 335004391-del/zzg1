import Foundation

/// 本地存储管理器 — 统一管理 UserDefaults 与文件缓存
final class StorageManager: Sendable {

    // MARK: - 单例

    static let shared = StorageManager()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - UserDefaults 读写

    /// 存储任意 Codable 对象
    func save<T: Codable>(_ value: T, forKey key: StorageKey) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key.rawValue)
        }
    }

    /// 读取 Codable 对象
    func load<T: Codable>(forKey key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    /// 删除指定 Key
    func remove(forKey key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }

    /// 清除所有存储（退出登录时使用）
    func clearAll() {
        StorageKey.allCases.forEach { defaults.removeObject(forKey: $0.rawValue) }
        AppLogger.info("本地存储已全部清除", category: .general)
    }
}

// MARK: - 存储 Key 枚举

/// 所有 UserDefaults Key 统一管理，避免字符串散落各处
enum StorageKey: String, CaseIterable {
    case authToken      = "auth_token"
    case currentUser    = "current_user"
    case appTheme       = "app_theme"
    case lastSyncTime   = "last_sync_time"
}
