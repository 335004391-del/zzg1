import Foundation

/// 房源 Mock 数据工厂 —— 自动生成大量随机但合理的房源数据
/// 仅用于开发 / Preview / 测试，禁止用于生产
enum MockHouseFactory {

    // MARK: - 基础语料

    private static let communities = [
        "碧桂园天玺", "绿城玉兰花园", "万科翡翠公园", "保利天悦", "融创外滩壹号",
        "中海寰宇天下", "龙湖天街", "招商雍华府", "华润城", "金地天境",
        "仁恒滨江园", "世茂滨江", "阳光城翡丽", "旭辉江山", "新城璞樾",
    ]
    private static let developers = [
        "碧桂园集团", "绿城中国", "万科集团", "保利发展", "融创中国",
        "中海地产", "龙湖集团", "招商蛇口", "华润置地", "金地集团",
    ]
    private static let streets = ["秀浦路", "华山路", "广富林路", "世纪大道", "南京西路",
                                  "陆家嘴环路", "虹桥路", "中山北路", "杨高南路", "漕溪北路"]

    // MARK: - 生成入口

    /// 生成指定数量的房源（默认 200）
    static func generate(count: Int = 200) -> [House] {
        (1...count).map { index in makeHouse(index: index) }
    }

    // MARK: - 单个房源构造

    private static func makeHouse(index: Int) -> House {
        var rng = SeededGenerator(seed: UInt64(index) &* 0x9E3779B1)

        let community = communities.randomElement(using: &rng)!
        let city      = HouseLocationOptions.cities.randomElement(using: &rng)!
        let district  = HouseLocationOptions.districts.randomElement(using: &rng)!
        let street    = streets.randomElement(using: &rng)!

        let rooms       = Int.random(in: 1...5, using: &rng)
        let livingRooms = rooms >= 3 ? 2 : 1
        let bathrooms   = rooms >= 4 ? 2 : 1
        let area        = Double(Int.random(in: 50...220, using: &rng))
        let unitPrice   = Double(Int.random(in: 15000...80000, using: &rng))
        let price       = (area * unitPrice / 10000).rounded() // 万元

        let totalFloors = Int.random(in: 6...42, using: &rng)
        let floor       = Int.random(in: 1...totalFloors, using: &rng)

        let decoration  = DecorationType.allCases.randomElement(using: &rng)!
        let orientation = OrientationType.allCases.filter { $0 != .any }.randomElement(using: &rng)!
        let propertyType = PropertyType.allCases.randomElement(using: &rng)!

        // 标签（1~4 个，去重）
        let tagPool = HouseTag.allCases
        let tagCount = Int.random(in: 1...4, using: &rng)
        let tags = Array(Set((0..<tagCount).map { _ in tagPool.randomElement(using: &rng)! }))

        let hasSubway = tags.contains(.subway) || Bool.random(using: &rng)
        let buildYear = Int.random(in: 2005...2024, using: &rng)

        let createdDaysAgo = Int.random(in: 0...120, using: &rng)
        let createdAt = Calendar.current.date(byAdding: .day, value: -createdDaysAgo, to: Date()) ?? Date()
        let updatedDaysAgo = Int.random(in: 0...createdDaysAgo + 1, using: &rng)
        let updatedAt = Calendar.current.date(byAdding: .day, value: -updatedDaysAgo, to: Date()) ?? Date()

        // 占位图片（3~6 张，仅作占位标识）
        let imageCount = Int.random(in: 3...6, using: &rng)
        let images = (0..<imageCount).map { "ph-\(index)-\($0)" }

        let title = "\(community) | \(decoration.displayName)\(rooms)房 | \(district)"

        return House(
            id:              "house-\(index)",
            houseCode:       String(format: "H2024%04d", index),
            title:           title,
            community:       community,
            city:            city,
            district:        district,
            address:         "\(district)\(street) \(Int.random(in: 1...2000, using: &rng)) 号",
            price:           price,
            unitPrice:       unitPrice,
            area:            area,
            rooms:           rooms,
            livingRooms:     livingRooms,
            bathrooms:       bathrooms,
            floor:           floor,
            totalFloors:     totalFloors,
            orientation:     orientation,
            decoration:      decoration,
            propertyType:    propertyType,
            buildYear:       buildYear,
            developer:       developers.randomElement(using: &rng),
            propertyCompany: "\(community)物业",
            parkingSpaces:   Int.random(in: 0...2, using: &rng),
            subwayDistance:  hasSubway ? Int.random(in: 100...1500, using: &rng) : nil,
            schoolInfo:      tags.contains(.school) ? "对口优质学区" : nil,
            description:     "\(community)，位于\(city)\(district)，\(decoration.displayName)交付，配套成熟，诚意出售。",
            advantages:      Self.makeAdvantages(tags: tags, decoration: decoration),
            images:          images,
            tags:            tags,
            status:          HouseStatus.allCases.randomElement(using: &rng)!,
            createdAt:       createdAt,
            updatedAt:       updatedAt,
            isFavorite:      Int.random(in: 0...4, using: &rng) == 0,
            aiRecommendScore: Int.random(in: 40...99, using: &rng),
            ownershipYears:  [70, 70, 70, 40, 50].randomElement(using: &rng)!
        )
    }

    private static func makeAdvantages(tags: [HouseTag], decoration: DecorationType) -> [String] {
        var list: [String] = []
        if tags.contains(.school)   { list.append("对口优质学区") }
        if tags.contains(.subway)   { list.append("近地铁通勤便利") }
        if tags.contains(.park)     { list.append("紧邻公园绿地") }
        if decoration == .fine || decoration == .luxury { list.append("\(decoration.displayName)即可入住") }
        if list.isEmpty { list.append("配套成熟，诚意出售") }
        return list
    }
}
