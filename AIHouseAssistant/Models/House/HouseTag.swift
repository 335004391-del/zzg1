import Foundation

/// 房源标签枚举 — 描述房源核心卖点特征，支持多选
enum HouseTag: String, Codable, CaseIterable, Identifiable, Hashable {

    case school     = "school"      // 学区
    case subway     = "subway"      // 地铁
    case park       = "park"        // 公园
    case commercial = "commercial"  // 商业中心
    case fineTuned  = "fine_tuned"  // 精装修
    case existing   = "existing"    // 现房
    case nearNew    = "near_new"    // 次新房
    case highRise   = "high_rise"   // 高层
    case house      = "house"       // 洋房
    case villa      = "villa"       // 别墅
    case duplex     = "duplex"      // 复式
    case scenery    = "scenery"     // 景观房

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .school:     return "学区"
        case .subway:     return "地铁"
        case .park:       return "公园"
        case .commercial: return "商业中心"
        case .fineTuned:  return "精装修"
        case .existing:   return "现房"
        case .nearNew:    return "次新房"
        case .highRise:   return "高层"
        case .house:      return "洋房"
        case .villa:      return "别墅"
        case .duplex:     return "复式"
        case .scenery:    return "景观房"
        }
    }

    var icon: String {
        switch self {
        case .school:     return "graduationcap.fill"
        case .subway:     return "tram.fill"
        case .park:       return "leaf.fill"
        case .commercial: return "storefront.fill"
        case .fineTuned:  return "paintbrush.fill"
        case .existing:   return "key.fill"
        case .nearNew:    return "sparkle"
        case .highRise:   return "building.2.fill"
        case .house:      return "house.fill"
        case .villa:      return "house.lodge.fill"
        case .duplex:     return "square.split.2x1.fill"
        case .scenery:    return "mountain.2.fill"
        }
    }
}
