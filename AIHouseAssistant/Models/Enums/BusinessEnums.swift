import Foundation

// MARK: - 客户状态

enum CustomerStatus: String, Codable, CaseIterable, Hashable {
    case active      = "active"       // 跟进中
    case highIntent  = "high_intent"  // 高意向
    case contracted  = "contracted"   // 已签约
    case inactive    = "inactive"     // 暂停跟进
    case lost        = "lost"         // 已流失

    var displayName: String {
        switch self {
        case .active:     return "跟进中"
        case .highIntent: return "高意向"
        case .contracted: return "已签约"
        case .inactive:   return "暂停跟进"
        case .lost:       return "已流失"
        }
    }

    /// 是否为活跃状态（需要继续跟进）
    var isActive: Bool {
        self == .active || self == .highIntent
    }
}

// MARK: - 购房目的

enum HousePurpose: String, Codable, CaseIterable, Hashable {
    case selfUse    = "self_use"    // 自住
    case investment = "investment"  // 投资
    case rental     = "rental"      // 出租
    case vacation   = "vacation"    // 度假
    case mixed      = "mixed"       // 自住+投资

    var displayName: String {
        switch self {
        case .selfUse:    return "自住"
        case .investment: return "投资"
        case .rental:     return "出租"
        case .vacation:   return "度假"
        case .mixed:      return "自住+投资"
        }
    }

    var icon: String {
        switch self {
        case .selfUse:    return "house.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .rental:     return "key.fill"
        case .vacation:   return "sun.max.fill"
        case .mixed:      return "square.split.2x1"
        }
    }
}

// MARK: - 付款方式

enum PaymentType: String, Codable, CaseIterable, Hashable {
    case fullPayment    = "full"      // 全款
    case mortgage       = "mortgage"  // 按揭贷款
    case combinedPayment = "combined" // 组合贷款（商贷+公积金）

    var displayName: String {
        switch self {
        case .fullPayment:     return "全款"
        case .mortgage:        return "按揭"
        case .combinedPayment: return "组合贷"
        }
    }
}

// MARK: - 贷款状态

enum LoanStatus: String, Codable, CaseIterable, Hashable {
    case notApplied  = "not_applied"  // 未申请
    case preApproved = "pre_approved" // 预审通过
    case approved    = "approved"     // 已批贷
    case rejected    = "rejected"     // 拒贷

    var displayName: String {
        switch self {
        case .notApplied:  return "未申请"
        case .preApproved: return "预审通过"
        case .approved:    return "已批贷"
        case .rejected:    return "拒贷"
        }
    }
}

// MARK: - 跟进类型

enum FollowType: String, Codable, CaseIterable, Hashable {
    case phone     = "phone"     // 电话
    case wechat    = "wechat"    // 微信
    case visit     = "visit"     // 上门拜访
    case带看      = "house_view" // 带看房源
    case negotiate = "negotiate" // 谈判
    case sign      = "sign"      // 签约
    case other     = "other"     // 其他

    var displayName: String {
        switch self {
        case .phone:     return "电话跟进"
        case .wechat:    return "微信沟通"
        case .visit:     return "上门拜访"
        case .带看:      return "带看房源"
        case .negotiate: return "价格谈判"
        case .sign:      return "签约确认"
        case .other:     return "其他"
        }
    }

    var icon: String {
        switch self {
        case .phone:     return "phone.fill"
        case .wechat:    return "message.fill"
        case .visit:     return "figure.walk"
        case .带看:      return "house.fill"
        case .negotiate: return "briefcase.fill"
        case .sign:      return "signature"
        case .other:     return "ellipsis.circle.fill"
        }
    }
}

// MARK: - AI 风险等级

enum RiskLevel: String, Codable, CaseIterable, Hashable {
    case low    = "low"    // 低风险（稳定客户）
    case medium = "medium" // 中风险
    case high   = "high"   // 高风险（可能流失）

    var displayName: String {
        switch self {
        case .low:    return "低风险"
        case .medium: return "中风险"
        case .high:   return "高风险"
        }
    }
}

// MARK: - AI 价格敏感度

enum PriceSensitivity: String, Codable, CaseIterable, Hashable {
    case low    = "low"    // 不敏感（预算充足）
    case medium = "medium" // 中等敏感
    case high   = "high"   // 高度敏感（价格是主要决策因素）

    var displayName: String {
        switch self {
        case .low:    return "不敏感"
        case .medium: return "中等"
        case .high:   return "高度敏感"
        }
    }
}
