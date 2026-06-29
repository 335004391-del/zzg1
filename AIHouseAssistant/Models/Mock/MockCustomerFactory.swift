import Foundation

/// 客户 Mock 数据工厂 —— 自动生成大量随机但合理的客户数据
/// 仅用于开发 / Preview / 测试，禁止用于生产
enum MockCustomerFactory {

    // MARK: - 基础语料

    private static let surnames = ["张", "王", "李", "赵", "陈", "刘", "杨", "黄", "周", "吴",
                                   "徐", "孙", "马", "朱", "胡", "郭", "何", "高", "林", "罗"]
    private static let givenNames = ["伟", "敏", "静", "丽", "强", "磊", "军", "洋", "勇", "艳",
                                     "杰", "娟", "涛", "明", "超", "霞", "平", "刚", "桂英", "建国"]
    private static let occupations = ["IT 工程师", "银行职员", "医生", "教师", "律师", "企业高管",
                                      "个体经营", "公务员", "设计师", "销售总监", "会计", "退休"]
    private static let companies = ["某科技有限公司", "某银行", "某医院", "某中学", "某律所",
                                    "某地产集团", "某贸易公司", "某事业单位", "某设计院", "自由职业"]

    // MARK: - 生成入口

    /// 生成指定数量的客户（默认 100）
    static func generate(count: Int = 100) -> [Customer] {
        (1...count).map { index in makeCustomer(index: index) }
    }

    // MARK: - 单个客户构造

    private static func makeCustomer(index: Int) -> Customer {
        var rng = SeededGenerator(seed: UInt64(index) &* 2654435761)

        let surname = surnames.randomElement(using: &rng)!
        let given   = givenNames.randomElement(using: &rng)!
        let name    = surname + given
        let gender: Gender = given.count > 1 || Bool.random(using: &rng) ? .male : .female

        // 预算（80~1200 万，按 10 取整）
        let budgetMin = Double(Int.random(in: 8...60, using: &rng) * 10)
        let budgetMax = budgetMin + Double(Int.random(in: 5...30, using: &rng) * 10)

        // 标签（1~3 个，去重）
        let tagPool = CustomerTag.allCases.filter { $0 != .any }
        let tagCount = Int.random(in: 1...3, using: &rng)
        let tags = Array(Set((0..<tagCount).map { _ in tagPool.randomElement(using: &rng)! }))

        // 区域（1~2 个）
        let areaCount = Int.random(in: 1...2, using: &rng)
        let areas = Array(Set((0..<areaCount).map { _ in CustomerAreaOptions.all.randomElement(using: &rng)! }))

        // 状态
        let status = CustomerStatus.allCases.randomElement(using: &rng)!

        // 时间
        let createdDaysAgo = Int.random(in: 0...180, using: &rng)
        let createdAt = Calendar.current.date(byAdding: .day, value: -createdDaysAgo, to: Date()) ?? Date()
        let lastContactDaysAgo = Int.random(in: 0...60, using: &rng)
        let lastContactAt = Calendar.current.date(byAdding: .day, value: -lastContactDaysAgo, to: Date())

        // 成交概率与 AI 评分（与状态弱关联，更真实）
        let baseProb: Int
        switch status {
        case .highIntent: baseProb = Int.random(in: 70...95, using: &rng)
        case .active:     baseProb = Int.random(in: 45...80, using: &rng)
        case .contracted: baseProb = Int.random(in: 90...99, using: &rng)
        case .inactive:   baseProb = Int.random(in: 20...50, using: &rng)
        case .lost:       baseProb = Int.random(in: 5...30, using: &rng)
        }
        let aiScore = min(100, max(0, baseProb + Int.random(in: -10...10, using: &rng)))

        return Customer(
            id:                  "mock-\(index)",
            customerCode:        String(format: "C2024%04d", index),
            name:                name,
            gender:              gender,
            phone:               String(format: "1%010d", 3_000_000_000 + index),
            wechat:              Bool.random(using: &rng) ? "wx_\(name)\(index)" : nil,
            avatar:              nil,
            birthday:            Calendar.current.date(from: DateComponents(
                                    year: Int.random(in: 1965...1998, using: &rng),
                                    month: Int.random(in: 1...12, using: &rng),
                                    day: Int.random(in: 1...28, using: &rng))),
            occupation:          occupations.randomElement(using: &rng),
            company:             companies.randomElement(using: &rng),
            annualIncome:        Double(Int.random(in: 20...150, using: &rng)),
            budgetMin:           budgetMin,
            budgetMax:           budgetMax,
            preferredArea:       areas,
            preferredDistrict:   [],
            housePurpose:        HousePurpose.allCases.randomElement(using: &rng)!,
            expectedAreaMin:     Double(Int.random(in: 6...10, using: &rng) * 10),
            expectedAreaMax:     Double(Int.random(in: 11...20, using: &rng) * 10),
            expectedRooms:       [Int.random(in: 1...4, using: &rng)],
            expectedDecoration:  [DecorationType.allCases.randomElement(using: &rng)!],
            paymentMethod:       PaymentType.allCases.randomElement(using: &rng)!,
            loanStatus:          LoanStatus.allCases.randomElement(using: &rng)!,
            familyMembers:       Int.random(in: 1...5, using: &rng),
            childrenCount:       Int.random(in: 0...2, using: &rng),
            schoolRequirement:   tags.contains(.school),
            subwayRequirement:   tags.contains(.subway),
            parkingRequirement:  Bool.random(using: &rng),
            preferredFloor:      FloorPreference.allCases.randomElement(using: &rng)!,
            preferredOrientation: [.south],
            tags:                tags,
            remark:              nil,
            status:              status,
            createdAt:           createdAt,
            updatedAt:           createdAt,
            isFavorite:          Int.random(in: 0...4, using: &rng) == 0, // 约 20% 收藏
            dealProbability:     baseProb,
            aiScore:             aiScore,
            lastContactAt:       lastContactAt
        )
    }
}
