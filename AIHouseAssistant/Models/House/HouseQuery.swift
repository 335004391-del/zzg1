import Foundation

/// 房源查询条件 —— 搜索 + 高级筛选 + 排序 + 分页 的统一载体
struct HouseQuery: Equatable {
    /// 关键词（小区 / 标题 / 地址 / 编号）
    var keyword: String = ""
    /// 高级筛选
    var filter: HouseFilter = HouseFilter()
    /// 排序方式
    var sort: HouseSortOption = .newest
    /// 仅看收藏
    var favoritesOnly: Bool = false
    /// 页码（从 1 开始）
    var page: Int = 1
    /// 每页数量
    var pageSize: Int = 20
}

// MARK: - 高级筛选

/// 房源高级筛选条件
struct HouseFilter: Equatable {
    /// 城市
    var cities: Set<String> = []
    /// 区域
    var districts: Set<String> = []
    /// 售价区间（万元）
    var priceMin: Double? = nil
    var priceMax: Double? = nil
    /// 面积区间（㎡）
    var areaMin: Double? = nil
    var areaMax: Double? = nil
    /// 户型（室）
    var rooms: Set<Int> = []
    /// 楼层偏好
    var floors: Set<FloorPreference> = []
    /// 装修
    var decorations: Set<DecorationType> = []
    /// 朝向
    var orientations: Set<OrientationType> = []
    /// 房屋类型
    var propertyTypes: Set<PropertyType> = []
    /// 标签
    var tags: Set<HouseTag> = []

    var isEmpty: Bool {
        cities.isEmpty && districts.isEmpty &&
        priceMin == nil && priceMax == nil &&
        areaMin == nil && areaMax == nil &&
        rooms.isEmpty && floors.isEmpty && decorations.isEmpty &&
        orientations.isEmpty && propertyTypes.isEmpty && tags.isEmpty
    }

    var activeCount: Int {
        var count = 0
        if !cities.isEmpty { count += 1 }
        if !districts.isEmpty { count += 1 }
        if priceMin != nil || priceMax != nil { count += 1 }
        if areaMin != nil || areaMax != nil { count += 1 }
        if !rooms.isEmpty { count += 1 }
        if !floors.isEmpty { count += 1 }
        if !decorations.isEmpty { count += 1 }
        if !orientations.isEmpty { count += 1 }
        if !propertyTypes.isEmpty { count += 1 }
        if !tags.isEmpty { count += 1 }
        return count
    }
}

// MARK: - 排序方式

enum HouseSortOption: String, CaseIterable, Identifiable {
    case newest      // 最新发布
    case priceAsc    // 价格从低到高
    case priceDesc   // 价格从高到低
    case areaDesc    // 面积从大到小
    case areaAsc     // 面积从小到大
    case updated     // 更新时间
    case aiRecommend // AI 推荐度（预留）

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newest:      return "最新发布"
        case .priceAsc:    return "价格从低到高"
        case .priceDesc:   return "价格从高到低"
        case .areaDesc:    return "面积从大到小"
        case .areaAsc:     return "面积从小到大"
        case .updated:     return "更新时间"
        case .aiRecommend: return "AI 推荐度"
        }
    }

    var icon: String {
        switch self {
        case .newest:      return "clock.badge.checkmark"
        case .priceAsc:    return "arrow.up.right.circle"
        case .priceDesc:   return "arrow.down.right.circle"
        case .areaDesc:    return "arrow.down.forward.square"
        case .areaAsc:     return "arrow.up.forward.square"
        case .updated:     return "calendar"
        case .aiRecommend: return "sparkles"
        }
    }
}

// MARK: - 楼层区间映射

extension House {
    /// 将具体楼层映射为楼层偏好（用于筛选）
    var floorCategory: FloorPreference {
        switch floor {
        case ..<7:    return .low
        case 7..<19:  return .mid
        default:      return .high
        }
    }
}

// MARK: - 可选项常量（Mock 阶段固定）

enum HouseLocationOptions {
    static let cities: [String] = ["上海", "北京", "杭州", "深圳", "广州", "苏州", "南京", "成都"]
    static let districts: [String] = [
        "浦东新区", "静安区", "徐汇区", "黄浦区", "闵行区",
        "松江区", "杨浦区", "普陀区", "宝山区", "青浦区",
    ]
}
