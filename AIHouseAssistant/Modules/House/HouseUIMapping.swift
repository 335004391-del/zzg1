import SwiftUI

/// 房源模块 UI 映射 —— 业务枚举到 Design System 视觉样式

extension HouseStatus {
    /// 状态标签样式
    var tagStyle: TagStyle {
        switch self {
        case .available: return .success
        case .reserved:  return .warning
        case .sold:      return .neutral
        case .offline:   return .error
        }
    }
}

extension HouseTag {
    /// 标签样式
    var tagStyle: TagStyle {
        switch self {
        case .school, .subway:        return .info
        case .park, .scenery:         return .success
        case .commercial, .highRise:  return .primary
        case .fineTuned:              return .warning
        case .existing, .nearNew:     return .info
        case .house, .villa, .duplex: return .neutral
        }
    }
}

/// 房源封面占位渐变 —— 无真实图片时，按种子生成稳定渐变色
enum HouseCoverPalette {
    private static let palettes: [[Color]] = [
        [Color(hex: "#4E73DF"), Color(hex: "#224ABE")],
        [Color(hex: "#1CC88A"), Color(hex: "#13855C")],
        [Color(hex: "#F6C23E"), Color(hex: "#DDA20A")],
        [Color(hex: "#E74A3B"), Color(hex: "#BE2617")],
        [Color(hex: "#36B9CC"), Color(hex: "#258391")],
        [Color(hex: "#6F42C1"), Color(hex: "#4B2A8A")],
    ]

    static func gradient(seed: Int) -> LinearGradient {
        let colors = palettes[seed % palettes.count]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
