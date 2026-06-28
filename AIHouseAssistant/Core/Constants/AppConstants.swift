import Foundation

/// 全局常量 — 避免魔法数字与硬编码字符串
enum AppConstants {

    // MARK: - App 信息
    static let appName    = "AI House Assistant"
    static let appVersion = "1.0"

    // MARK: - 动画时长
    enum Animation {
        static let fast:    Double = 0.15
        static let normal:  Double = 0.25
        static let slow:    Double = 0.4
    }

    // MARK: - 分页
    enum Pagination {
        static let defaultSize = 20
        static let maxSize     = 100
    }

    // MARK: - AI 匹配评分
    enum MatchScore {
        static let highThreshold:   Double = 0.8
        static let mediumThreshold: Double = 0.6
        static let lowThreshold:    Double = 0.4
    }
}
