import Foundation

/// 客户标签枚举 — 描述客户购房需求特征，支持多选
enum CustomerTag: String, Codable, CaseIterable, Identifiable, Hashable {

    case wedding    = "wedding"     // 婚房
    case upgrade    = "upgrade"     // 改善
    case retirement = "retirement"  // 养老
    case investment = "investment"  // 投资
    case school     = "school"      // 学区
    case subway     = "subway"      // 地铁
    case rigid      = "rigid"       // 刚需
    case luxury     = "luxury"      // 豪宅
    case river      = "river"       // 江景
    case lake       = "lake"        // 河景
    case any        = "any"         // 不限

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wedding:    return "婚房"
        case .upgrade:    return "改善"
        case .retirement: return "养老"
        case .investment: return "投资"
        case .school:     return "学区"
        case .subway:     return "地铁"
        case .rigid:      return "刚需"
        case .luxury:     return "豪宅"
        case .river:      return "江景"
        case .lake:       return "河景"
        case .any:        return "不限"
        }
    }

    var icon: String {
        switch self {
        case .wedding:    return "heart.fill"
        case .upgrade:    return "arrow.up.circle.fill"
        case .retirement: return "figure.stand"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .school:     return "graduationcap.fill"
        case .subway:     return "tram.fill"
        case .rigid:      return "house.fill"
        case .luxury:     return "crown.fill"
        case .river:      return "water.waves"
        case .lake:       return "water.waves"
        case .any:        return "checkmark.circle.fill"
        }
    }
}
