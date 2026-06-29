import Foundation

// MARK: - 房产类型

enum PropertyType: String, Codable, CaseIterable, Hashable {
    case apartment  = "apartment"   // 公寓
    case house      = "house"       // 洋房
    case villa      = "villa"       // 别墅
    case duplex     = "duplex"      // 复式
    case townhouse  = "townhouse"   // 联排
    case office     = "office"      // 办公
    case shop       = "shop"        // 商铺

    var displayName: String {
        switch self {
        case .apartment:  return "公寓"
        case .house:      return "洋房"
        case .villa:      return "别墅"
        case .duplex:     return "复式"
        case .townhouse:  return "联排"
        case .office:     return "办公"
        case .shop:       return "商铺"
        }
    }
}

// MARK: - 装修情况

enum DecorationType: String, Codable, CaseIterable, Hashable {
    case rough      = "rough"       // 毛坯
    case simple     = "simple"      // 简装
    case medium     = "medium"      // 中装
    case fine       = "fine"        // 精装修
    case luxury     = "luxury"      // 豪装

    var displayName: String {
        switch self {
        case .rough:    return "毛坯"
        case .simple:   return "简装"
        case .medium:   return "中装"
        case .fine:     return "精装修"
        case .luxury:   return "豪装"
        }
    }
}

// MARK: - 朝向

enum OrientationType: String, Codable, CaseIterable, Hashable {
    case east      = "east"       // 东
    case south     = "south"      // 南
    case west      = "west"       // 西
    case north     = "north"      // 北
    case southEast = "south_east" // 东南
    case southWest = "south_west" // 西南
    case northEast = "north_east" // 东北
    case northWest = "north_west" // 西北
    case any       = "any"        // 不限

    var displayName: String {
        switch self {
        case .east:      return "东"
        case .south:     return "南"
        case .west:      return "西"
        case .north:     return "北"
        case .southEast: return "东南"
        case .southWest: return "西南"
        case .northEast: return "东北"
        case .northWest: return "西北"
        case .any:       return "不限"
        }
    }
}

// MARK: - 楼层偏好

enum FloorPreference: String, Codable, CaseIterable, Hashable {
    case low  = "low"   // 低层（1~6F）
    case mid  = "mid"   // 中层（7~18F）
    case high = "high"  // 高层（19F+）
    case any  = "any"   // 不限

    var displayName: String {
        switch self {
        case .low:  return "低层"
        case .mid:  return "中层"
        case .high: return "高层"
        case .any:  return "不限"
        }
    }

    var rangeDescription: String {
        switch self {
        case .low:  return "1~6 层"
        case .mid:  return "7~18 层"
        case .high: return "19 层以上"
        case .any:  return "不限楼层"
        }
    }
}

// MARK: - 房源状态

enum HouseStatus: String, Codable, CaseIterable, Hashable {
    case available = "available"   // 在售
    case reserved  = "reserved"    // 已预留（认购）
    case sold      = "sold"        // 已售出
    case offline   = "offline"     // 已下架

    var displayName: String {
        switch self {
        case .available: return "在售"
        case .reserved:  return "已认购"
        case .sold:      return "已售出"
        case .offline:   return "已下架"
        }
    }

    /// 是否可以被匹配推荐
    var isMatchable: Bool { self == .available }
}
