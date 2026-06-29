import SwiftUI

/// 客户模块 UI 映射 —— 将业务枚举映射为 Design System 视觉样式
/// 模型层保持纯净，颜色 / 样式映射集中于此

extension CustomerStatus {
    /// 状态对应的标签样式
    var tagStyle: TagStyle {
        switch self {
        case .active:     return .info
        case .highIntent: return .success
        case .contracted: return .primary
        case .inactive:   return .neutral
        case .lost:       return .error
        }
    }
}

extension CustomerTag {
    /// 标签对应的展示样式
    var tagStyle: TagStyle {
        switch self {
        case .school, .subway: return .info
        case .investment, .luxury: return .primary
        case .rigid, .wedding:     return .warning
        case .retirement, .upgrade: return .success
        case .river, .lake:        return .info
        case .any:                 return .neutral
        }
    }
}

/// 成交概率 → 颜色（高=绿 / 中=橙 / 低=灰）
enum DealProbabilityStyle {
    static func color(_ value: Int) -> Color {
        switch value {
        case 80...:   return AppColor.success
        case 60..<80: return AppColor.warning
        case 40..<60: return AppColor.info
        default:      return AppColor.textSecondary
        }
    }
}
