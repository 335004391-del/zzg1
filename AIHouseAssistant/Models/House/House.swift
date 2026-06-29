import Foundation

/// 房源模型 — 核心房产实体
struct House: Codable, Identifiable, Hashable {

    // MARK: - 基础信息

    /// 系统唯一 ID
    var id: String
    /// 房源编号（如 H2024001）
    var houseCode: String
    /// 标题（展示用，如"碧桂园·天玺 | 南向三房 | 地铁口"）
    var title: String
    /// 小区名称
    var community: String
    /// 城市
    var city: String
    /// 区域（行政区，如"浦东新区"）
    var district: String
    /// 详细地址
    var address: String

    // MARK: - 价格

    /// 总价（万元）
    var price: Double
    /// 单价（元/㎡）
    var unitPrice: Double

    // MARK: - 户型

    /// 建筑面积（㎡）
    var area: Double
    /// 居室数（卧室）
    var rooms: Int
    /// 客厅数
    var livingRooms: Int
    /// 卫生间数
    var bathrooms: Int

    // MARK: - 楼层

    /// 所在楼层
    var floor: Int
    /// 总楼层
    var totalFloors: Int

    // MARK: - 建筑属性

    /// 主朝向
    var orientation: OrientationType
    /// 装修情况
    var decoration: DecorationType
    /// 物业类型
    var propertyType: PropertyType
    /// 建筑年份
    var buildYear: Int
    /// 开发商
    var developer: String?
    /// 物业公司
    var propertyCompany: String?
    /// 车位数
    var parkingSpaces: Int

    // MARK: - 配套

    /// 距地铁距离（米，nil 表示无地铁）
    var subwayDistance: Int?
    /// 学校信息（如"对口XX小学"）
    var schoolInfo: String?

    // MARK: - 描述

    /// 房源描述
    var description: String?
    /// 核心优势（列表）
    var advantages: [String]
    /// 图片 URL 列表
    var images: [String]

    // MARK: - 标签 & 状态

    /// 房源标签
    var tags: [HouseTag]
    /// 房源状态
    var status: HouseStatus
    /// 创建时间
    var createdAt: Date
    /// 最后更新时间
    var updatedAt: Date

    // MARK: - CRM 状态（房源管理模块）

    /// 是否收藏
    var isFavorite: Bool = false
    /// AI 推荐度（0~100，预留排序用）
    var aiRecommendScore: Int = 0
    /// 产权年限（年）
    var ownershipYears: Int = 70

    // MARK: - 计算属性

    /// 总价格式化（如"285万"）
    var priceDescription: String { "\(Int(price)) 万" }

    /// 产权描述（如"70 年产权"）
    var ownershipDescription: String { "\(ownershipYears) 年产权" }

    /// 封面占位配色种子（无真实图片时用于生成稳定渐变）
    var coverSeed: Int { abs(id.hashValue) }

    /// 更新时间描述（如"3 天前"）
    var updatedDescription: String {
        let days = Calendar.current.dateComponents([.day], from: updatedAt, to: Date()).day ?? 0
        switch days {
        case ..<1:   return "今天更新"
        case 1:      return "昨天更新"
        case 2...30: return "\(days) 天前更新"
        default:     return "\(days / 30) 个月前更新"
        }
    }

    /// 单价格式化（如"42,000元/㎡"）
    var unitPriceDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let str = formatter.string(from: NSNumber(value: Int(unitPrice))) ?? "\(Int(unitPrice))"
        return "\(str) 元/㎡"
    }

    /// 户型描述（如"3室2厅1卫"）
    var layoutDescription: String { "\(rooms)室\(livingRooms)厅\(bathrooms)卫" }

    /// 楼层描述（如"18/32层"）
    var floorDescription: String { "\(floor)/\(totalFloors)层" }

    /// 面积描述
    var areaDescription: String { "\(area)㎡" }

    /// 是否有地铁
    var hasSubway: Bool { subwayDistance != nil }
}

// MARK: - House Extension

extension House {

    /// 构造一个新房源（含默认值）
    static func new(title: String, community: String) -> House {
        House(
            id:              UUID().uuidString,
            houseCode:       "",
            title:           title,
            community:       community,
            city:            "",
            district:        "",
            address:         "",
            price:           0,
            unitPrice:       0,
            area:            90,
            rooms:           3,
            livingRooms:     2,
            bathrooms:       1,
            floor:           10,
            totalFloors:     32,
            orientation:     .south,
            decoration:      .fine,
            propertyType:    .apartment,
            buildYear:       2020,
            developer:       nil,
            propertyCompany: nil,
            parkingSpaces:   1,
            subwayDistance:  nil,
            schoolInfo:      nil,
            description:     nil,
            advantages:      [],
            images:          [],
            tags:            [],
            status:          .available,
            createdAt:       Date(),
            updatedAt:       Date()
        )
    }
}
