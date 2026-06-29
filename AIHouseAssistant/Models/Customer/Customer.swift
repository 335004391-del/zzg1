import Foundation

/// 客户模型 — 核心客户实体，贯穿整个销售流程
struct Customer: Codable, Identifiable, Hashable {

    // MARK: - 基础信息

    /// 系统唯一 ID（UUID 字符串）
    var id: String
    /// 客户编号（如 C2024001，人工可识别）
    var customerCode: String
    /// 姓名
    var name: String
    /// 性别
    var gender: Gender
    /// 手机号（主要联系方式）
    var phone: String
    /// 微信号
    var wechat: String?
    /// 头像 URL
    var avatar: String?
    /// 出生日期
    var birthday: Date?

    // MARK: - 职业信息

    /// 职业
    var occupation: String?
    /// 公司名称
    var company: String?
    /// 年收入（万元）
    var annualIncome: Double?

    // MARK: - 购房需求

    /// 预算下限（万元）
    var budgetMin: Double
    /// 预算上限（万元）
    var budgetMax: Double
    /// 意向区域（如"浦东新区"、"闵行"）
    var preferredArea: [String]
    /// 意向板块（小地名，如"碧桂园板块"）
    var preferredDistrict: [String]
    /// 购房目的
    var housePurpose: HousePurpose
    /// 期望面积下限（㎡）
    var expectedAreaMin: Double?
    /// 期望面积上限（㎡）
    var expectedAreaMax: Double?
    /// 期望房间数（可多选，如 [2, 3] 表示二房或三房）
    var expectedRooms: [Int]
    /// 期望装修（可多选）
    var expectedDecoration: [DecorationType]
    /// 付款方式
    var paymentMethod: PaymentType
    /// 贷款状态
    var loanStatus: LoanStatus

    // MARK: - 家庭信息

    /// 家庭人口数
    var familyMembers: Int
    /// 子女数量
    var childrenCount: Int
    /// 是否需要学区
    var schoolRequirement: Bool
    /// 是否需要靠近地铁
    var subwayRequirement: Bool
    /// 是否需要车位
    var parkingRequirement: Bool

    // MARK: - 偏好

    /// 楼层偏好
    var preferredFloor: FloorPreference
    /// 朝向偏好（可多选）
    var preferredOrientation: [OrientationType]

    // MARK: - 标签 & 备注

    /// 客户标签
    var tags: [CustomerTag]
    /// 备注
    var remark: String?

    // MARK: - 系统字段

    /// 客户状态
    var status: CustomerStatus
    /// 创建时间
    var createdAt: Date
    /// 最后更新时间
    var updatedAt: Date

    // MARK: - CRM 状态（客户管理模块）

    /// 是否收藏（销售重点关注）
    var isFavorite: Bool = false
    /// 成交概率（0~100，AI 预测，Mock）
    var dealProbability: Int = 0
    /// AI 综合评分（0~100，Mock）
    var aiScore: Int = 0
    /// 最近联系时间
    var lastContactAt: Date? = nil

    // MARK: - 计算属性

    /// 预算描述（格式化显示）
    var budgetDescription: String {
        "\(Int(budgetMin)) ~ \(Int(budgetMax)) 万"
    }

    /// 最近联系时间描述（如 "3 天前" / "从未联系"）
    var lastContactDescription: String {
        guard let date = lastContactAt else { return "从未联系" }
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        switch days {
        case ..<0:    return "今天"
        case 0:       return "今天"
        case 1:       return "昨天"
        case 2...30:  return "\(days) 天前"
        default:      return "\(days / 30) 个月前"
        }
    }

    /// 主要意向区域（取第一个，无则"不限"）
    var primaryArea: String { preferredArea.first ?? "不限" }

    /// 头像占位首字
    var avatarText: String { String(name.prefix(1)) }

    /// 面积描述
    var areaDescription: String {
        let min = expectedAreaMin.map { "\(Int($0))" } ?? "不限"
        let max = expectedAreaMax.map { "\(Int($0))㎡" } ?? "不限"
        if expectedAreaMin == nil && expectedAreaMax == nil { return "不限" }
        return "\(min) ~ \(max)"
    }

    /// 房间数描述（如"2~3 房"）
    var roomsDescription: String {
        guard !expectedRooms.isEmpty else { return "不限" }
        let sorted = expectedRooms.sorted()
        if sorted.count == 1 { return "\(sorted[0]) 房" }
        return "\(sorted.first!)~\(sorted.last!) 房"
    }

    /// 是否为高意向客户
    var isHighIntent: Bool { status == .highIntent }
}

// MARK: - Customer Extension（预留扩展点）

extension Customer {

    /// 构造一个新客户（含默认值）
    static func new(name: String, phone: String) -> Customer {
        Customer(
            id:                  UUID().uuidString,
            customerCode:        "",
            name:                name,
            gender:              .other,
            phone:               phone,
            wechat:              nil,
            avatar:              nil,
            birthday:            nil,
            occupation:          nil,
            company:             nil,
            annualIncome:        nil,
            budgetMin:           100,
            budgetMax:           300,
            preferredArea:       [],
            preferredDistrict:   [],
            housePurpose:        .selfUse,
            expectedAreaMin:     nil,
            expectedAreaMax:     nil,
            expectedRooms:       [3],
            expectedDecoration:  [.fine],
            paymentMethod:       .mortgage,
            loanStatus:          .notApplied,
            familyMembers:       3,
            childrenCount:       1,
            schoolRequirement:   false,
            subwayRequirement:   false,
            parkingRequirement:  true,
            preferredFloor:      .any,
            preferredOrientation: [.south],
            tags:                [],
            remark:              nil,
            status:              .active,
            createdAt:           Date(),
            updatedAt:           Date()
        )
    }
}
