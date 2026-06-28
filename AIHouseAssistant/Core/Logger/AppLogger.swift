import Foundation
import OSLog

/// 统一日志系统 — 封装 OSLog，支持分级打印
struct AppLogger {

    // MARK: - 日志分类

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.aihouseassistant"

    private static let networkLog = Logger(subsystem: subsystem, category: "Network")
    private static let uiLog      = Logger(subsystem: subsystem, category: "UI")
    private static let aiLog      = Logger(subsystem: subsystem, category: "AI")
    private static let dbLog      = Logger(subsystem: subsystem, category: "Database")
    private static let generalLog = Logger(subsystem: subsystem, category: "General")

    // MARK: - 通用日志

    static func debug(_ message: String, category: Category = .general) {
        logger(for: category).debug("🔍 \(message, privacy: .public)")
    }

    static func info(_ message: String, category: Category = .general) {
        logger(for: category).info("ℹ️ \(message, privacy: .public)")
    }

    static func warning(_ message: String, category: Category = .general) {
        logger(for: category).warning("⚠️ \(message, privacy: .public)")
    }

    static func error(_ message: String, category: Category = .general, error: Error? = nil) {
        if let error {
            logger(for: category).error("❌ \(message, privacy: .public) | Error: \(error.localizedDescription, privacy: .public)")
        } else {
            logger(for: category).error("❌ \(message, privacy: .public)")
        }
    }

    // MARK: - 分类枚举

    enum Category {
        case network
        case ui
        case ai
        case database
        case general
    }

    // MARK: - 内部路由

    private static func logger(for category: Category) -> Logger {
        switch category {
        case .network:  return networkLog
        case .ui:       return uiLog
        case .ai:       return aiLog
        case .database: return dbLog
        case .general:  return generalLog
        }
    }
}
