import SwiftUI

/// 匹配模块 UI 映射 —— 等级/分数到 Design System 视觉样式

extension MatchLevel {
    /// 等级主色
    var appColor: Color {
        switch self {
        case .excellent: return AppColor.success
        case .good:      return AppColor.primary
        case .fair:      return AppColor.warning
        case .poor:      return AppColor.error
        }
    }

    /// 等级标签样式
    var tagStyle: TagStyle {
        switch self {
        case .excellent: return .success
        case .good:      return .primary
        case .fair:      return .warning
        case .poor:      return .error
        }
    }
}

/// 分值 → 颜色（用于评分条 / 雷达图）
enum MatchScoreColor {
    static func color(_ value: Double) -> Color {
        switch value {
        case 90...:   return AppColor.success
        case 75..<90: return AppColor.primary
        case 60..<75: return AppColor.warning
        default:      return AppColor.error
        }
    }
}

// MARK: - 分享文案

extension MatchRecommendation {
    /// 生成可分享的推荐文案
    var shareText: String {
        var text = "【为 \(customer.name) 推荐房源】\n"
        text += "\(house.title)\n"
        text += "总价：\(house.priceDescription) · \(house.layoutDescription) · \(house.areaDescription)\n"
        text += "匹配度：\(scoreInt) 分（\(level.displayName)）\n"
        if !reasons.isEmpty {
            text += "推荐理由：" + reasons.prefix(3).joined(separator: "；")
        }
        return text
    }
}
