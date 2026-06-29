import SwiftUI

/// 将统计配色语义映射为 Design System 中的具体颜色
/// 模型层（Foundation）保持纯净，颜色映射只存在于 View 层
extension DashboardStatAccent {

    /// 前景主色
    var color: Color {
        switch self {
        case .blue:   return AppColor.primary
        case .green:  return AppColor.success
        case .orange: return AppColor.warning
        case .purple: return AppColor.aiPurple
        case .red:    return AppColor.error
        case .gold:   return AppColor.aiGold
        }
    }

    /// 浅色背景（图标底圈）
    var softBackground: Color {
        color.opacity(0.12)
    }
}
