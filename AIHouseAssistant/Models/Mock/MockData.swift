import Foundation

/// Mock 数据中心 — 提供所有模型的预览/测试用示例数据
/// 仅用于 SwiftUI Preview 和 Unit Test，禁止在生产代码中使用
enum MockData {

    // MARK: - Customer

    static let customer1 = Customer(
        id:                  "c-001",
        customerCode:        "C2024001",
        name:                "张伟",
        gender:              .male,
        phone:               "138 0000 1001",
        wechat:              "zhangwei_house",
        avatar:              nil,
        birthday:            Calendar.current.date(from: DateComponents(year: 1985, month: 6, day: 15)),
        occupation:          "IT 工程师",
        company:             "某科技有限公司",
        annualIncome:        60,
        budgetMin:           200,
        budgetMax:           320,
        preferredArea:       ["浦东新区"],
        preferredDistrict:   ["碧桂园板块", "张江板块"],
        housePurpose:        .selfUse,
        expectedAreaMin:     90,
        expectedAreaMax:     130,
        expectedRooms:       [3],
        expectedDecoration:  [.fine],
        paymentMethod:       .mortgage,
        loanStatus:          .preApproved,
        familyMembers:       3,
        childrenCount:       1,
        schoolRequirement:   true,
        subwayRequirement:   true,
        parkingRequirement:  true,
        preferredFloor:      .mid,
        preferredOrientation: [.south, .southEast],
        tags:                [.school, .subway, .rigid],
        remark:              "孩子明年上小学，学区是硬需求",
        status:              .highIntent,
        createdAt:           mockDate(daysAgo: 30),
        updatedAt:           mockDate(daysAgo: 2)
    )

    static let customer2 = Customer(
        id:                  "c-002",
        customerCode:        "C2024002",
        name:                "李梅",
        gender:              .female,
        phone:               "139 0000 2002",
        wechat:              nil,
        avatar:              nil,
        birthday:            Calendar.current.date(from: DateComponents(year: 1975, month: 3, day: 22)),
        occupation:          "银行职员",
        company:             "某银行",
        annualIncome:        40,
        budgetMin:           350,
        budgetMax:           500,
        preferredArea:       ["静安区", "长宁区"],
        preferredDistrict:   [],
        housePurpose:        .upgrade,
        expectedAreaMin:     130,
        expectedAreaMax:     200,
        expectedRooms:       [4],
        expectedDecoration:  [.fine, .luxury],
        paymentMethod:       .combinedPayment,
        loanStatus:          .approved,
        familyMembers:       4,
        childrenCount:       2,
        schoolRequirement:   false,
        subwayRequirement:   false,
        parkingRequirement:  true,
        preferredFloor:      .high,
        preferredOrientation: [.south],
        tags:                [.upgrade, .luxury],
        remark:              "现有房子不够住，想换大一点的",
        status:              .active,
        createdAt:           mockDate(daysAgo: 15),
        updatedAt:           mockDate(daysAgo: 5)
    )

    static let customer3 = Customer(
        id:                  "c-003",
        customerCode:        "C2024003",
        name:                "王建国",
        gender:              .male,
        phone:               "137 0000 3003",
        wechat:              "wangjg2024",
        avatar:              nil,
        birthday:            Calendar.current.date(from: DateComponents(year: 1960, month: 11, day: 8)),
        occupation:          "退休",
        company:             nil,
        annualIncome:        nil,
        budgetMin:           80,
        budgetMax:           150,
        preferredArea:       ["松江区"],
        preferredDistrict:   [],
        housePurpose:        .retirement,
        expectedAreaMin:     60,
        expectedAreaMax:     90,
        expectedRooms:       [2],
        expectedDecoration:  [.simple, .medium],
        paymentMethod:       .fullPayment,
        loanStatus:          .notApplied,
        familyMembers:       2,
        childrenCount:       0,
        schoolRequirement:   false,
        subwayRequirement:   false,
        parkingRequirement:  true,
        preferredFloor:      .low,
        preferredOrientation: [.south, .southEast],
        tags:                [.retirement],
        remark:              "退休养老房，最好带花园",
        status:              .active,
        createdAt:           mockDate(daysAgo: 7),
        updatedAt:           mockDate(daysAgo: 1)
    )

    static let customers: [Customer] = [customer1, customer2, customer3]

    // MARK: - House

    static let house1 = House(
        id:              "h-001",
        houseCode:       "H2024001",
        title:           "碧桂园·天玺 | 精装南向三房 | 地铁口",
        community:       "碧桂园天玺",
        city:            "上海",
        district:        "浦东新区",
        address:         "浦东新区秀浦路 888 号",
        price:           285,
        unitPrice:       27142,
        area:            105,
        rooms:           3,
        livingRooms:     2,
        bathrooms:       1,
        floor:           18,
        totalFloors:     32,
        orientation:     .south,
        decoration:      .fine,
        propertyType:    .apartment,
        buildYear:       2021,
        developer:       "碧桂园集团",
        propertyCompany: "碧桂园物业",
        parkingSpaces:   1,
        subwayDistance:  350,
        schoolInfo:      "对口张江实验小学",
        description:     "碧桂园天玺，浦东核心地段，精装交付，配套成熟。",
        advantages:      ["对口优质学区", "350米到地铁", "全精装入住", "南向采光好"],
        images:          [],
        tags:            [.school, .subway, .fineTuned, .existing],
        status:          .available,
        createdAt:       mockDate(daysAgo: 60),
        updatedAt:       mockDate(daysAgo: 3)
    )

    static let house2 = House(
        id:              "h-002",
        houseCode:       "H2024002",
        title:           "绿城·玉兰花园 | 豪装四房 | 静安核心",
        community:       "绿城玉兰花园",
        city:            "上海",
        district:        "静安区",
        address:         "静安区华山路 1088 号",
        price:           458,
        unitPrice:       34462,
        area:            133,
        rooms:           4,
        livingRooms:     2,
        bathrooms:       2,
        floor:           26,
        totalFloors:     33,
        orientation:     .southEast,
        decoration:      .luxury,
        propertyType:    .apartment,
        buildYear:       2019,
        developer:       "绿城中国",
        propertyCompany: "绿城物业",
        parkingSpaces:   2,
        subwayDistance:  nil,
        schoolInfo:      nil,
        description:     "绿城出品，豪装四房，静安稀缺盘，全龄配套齐全。",
        advantages:      ["绿城品质物业", "豪装四房", "高区视野开阔", "静安稀缺大盘"],
        images:          [],
        tags:            [.commercial, .fineTuned, .highRise],
        status:          .available,
        createdAt:       mockDate(daysAgo: 45),
        updatedAt:       mockDate(daysAgo: 1)
    )

    static let house3 = House(
        id:              "h-003",
        houseCode:       "H2024003",
        title:           "万科·翡翠公园 | 低密洋房 | 近公园",
        community:       "万科翡翠公园",
        city:            "上海",
        district:        "松江区",
        address:         "松江区广富林路 99 号",
        price:           128,
        unitPrice:       17778,
        area:            72,
        rooms:           2,
        livingRooms:     1,
        bathrooms:       1,
        floor:           3,
        totalFloors:     6,
        orientation:     .south,
        decoration:      .medium,
        propertyType:    .house,
        buildYear:       2018,
        developer:       "万科集团",
        propertyCompany: "万科物业",
        parkingSpaces:   1,
        subwayDistance:  nil,
        schoolInfo:      nil,
        description:     "低密洋房，紧邻广富林遗址公园，适合退休养老。",
        advantages:      ["低密低层适合老人", "公园资源", "安静宜居", "万科品牌保障"],
        images:          [],
        tags:            [.park, .house, .nearNew],
        status:          .available,
        createdAt:       mockDate(daysAgo: 20),
        updatedAt:       mockDate(daysAgo: 2)
    )

    static let houses: [House] = [house1, house2, house3]

    // MARK: - MatchResult

    static let matchResult1 = MatchResult(
        id:            "m-001",
        customerId:    "c-001",
        houseId:       "h-001",
        matchScore:    88.5,
        budgetScore:   90.0,
        locationScore: 92.0,
        areaScore:     85.0,
        layoutScore:   88.0,
        tagScore:      95.0,
        aiScore:       82.0,
        reason:        "张伟需要浦东学区房，碧桂园天玺对口张江实验小学，预算 285 万处于客户预算区间内，三房面积 105㎡ 符合期望，精装交付节省装修时间，地铁口位置满足通勤需求。综合匹配度极高，强烈推荐优先带看。",
        shortReason:   "学区+地铁+精装，完美契合需求",
        riskPoints:    ["单价略高于客户心理预期", "需确认车位费用"],
        createdAt:     mockDate(daysAgo: 1)
    )

    static let matchResults: [MatchResult] = [matchResult1]

    // MARK: - AIProfile

    static let aiProfile1 = AIProfile(
        id:                  "ap-001",
        customerId:          "c-001",
        summary:             "张伟是一位典型的理性型首套置业客户，IT 从业背景使其决策时注重数据和性价比。子女入学压力使学区成为核心需求，不可妥协。家庭年收入约 60 万，贷款能力充足，成交意愿强烈。",
        personality:         "理性决策型",
        purchasePurpose:     "子女教育驱动的首套置业，时间压力明显（孩子明年入学）",
        priceSensitivity:    .medium,
        preferredStyle:      "现代简约，偏好功能性布局",
        preferredLocation:   "浦东新区，优质学区板块",
        familyAnalysis:      "三口之家，孩子即将上小学，对学区有强需求。夫妻双方均有工作，通勤便利也是重要考量。",
        riskLevel:           .low,
        purchaseProbability: 0.82,
        aiSuggestion:        "重点强调学区对口资质和地铁通勤优势。可邀请带看碧桂园天玺，着重介绍小学对口情况。建议尽快推进，明年入学时间窗口紧迫。",
        keyBreakthrough:     ["子女教育是核心关切，学区是打动点", "可接受按揭，贷款已预审通过，资金无障碍", "时间敏感，应创造紧迫感"],
        avoidTopics:         ["不要过多讨论投资收益（自住为主）", "暂不提楼市风险话题"],
        lastUpdated:         mockDate(daysAgo: 1)
    )

    // MARK: - FollowRecord

    static let followRecord1 = FollowRecord(
        id:               "f-001",
        customerId:       "c-001",
        salesId:          "u-001",
        salesName:        "陈销售",
        followType:       .phone,
        content:          "电话沟通，确认客户预算范围 200~320 万，明确需要学区房，最快本月内看房。客户对碧桂园天玺有兴趣，约好下周末带看。",
        durationMinutes:  25,
        visitedHouseIds:  [],
        customerFeedback: "对学区和地铁位置很满意，对价格有轻微顾虑",
        nextFollowDate:   Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        nextFollowPlan:   "带看碧桂园天玺，主推 18 层南向户型",
        createdAt:        mockDate(daysAgo: 3)
    )

    static let followRecords: [FollowRecord] = [followRecord1]

    // MARK: - User

    static let user1 = User(
        id:         "u-001",
        name:       "陈伟",
        avatar:     nil,
        phone:      "138 8888 0001",
        email:      "chenwei@company.com",
        role:       .sales,
        department: "浦东销售部",
        store:      "张江门店",
        status:     .active,
        createdAt:  mockDate(daysAgo: 365)
    )

    static let currentUser = user1

    // MARK: - DashboardStat

    static let dashboardStat = DashboardStat(
        customerCount:           128,
        highProbabilityCustomer: 23,
        warningCustomer:         7,
        houseCount:              56,
        todayFollow:             8,
        todayNewCustomer:        3,
        todayNewHouse:           1,
        matchSuccessRate:        0.73,
        monthlyDealCount:        8,
        monthlyNewCustomer:      31
    )

    // MARK: - 辅助方法

    /// 生成 N 天前的 Date
    private static func mockDate(daysAgo days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}
