import Foundation

/// 跟进记录模型 — 销售对客户的每次联系记录
struct FollowRecord: Codable, Identifiable, Hashable {

    // MARK: - 基础

    /// 系统唯一 ID
    var id: String
    /// 对应客户 ID
    var customerId: String
    /// 跟进销售的用户 ID
    var salesId: String
    /// 销售姓名（冗余存储，避免关联查询）
    var salesName: String?

    // MARK: - 跟进内容

    /// 跟进类型
    var followType: FollowType
    /// 跟进内容详情
    var content: String
    /// 本次跟进时长（分钟，电话/拜访有效）
    var durationMinutes: Int?
    /// 本次带看的房源 ID（带看时有效）
    var visitedHouseIds: [String]

    // MARK: - 结果 & 计划

    /// 客户反馈（AI 分析使用）
    var customerFeedback: String?
    /// 下次跟进计划日期
    var nextFollowDate: Date?
    /// 下次跟进计划内容
    var nextFollowPlan: String?

    // MARK: - 时间

    /// 跟进发生时间
    var createdAt: Date

    // MARK: - 计算属性

    /// 是否已安排下次跟进
    var hasNextFollow: Bool { nextFollowDate != nil }

    /// 是否逾期（下次跟进日期已过）
    var isOverdue: Bool {
        guard let next = nextFollowDate else { return false }
        return next < Date()
    }
}

// MARK: - FollowRecord Extension

extension FollowRecord {

    static func new(customerId: String, salesId: String, type: FollowType, content: String) -> FollowRecord {
        FollowRecord(
            id:               UUID().uuidString,
            customerId:       customerId,
            salesId:          salesId,
            salesName:        nil,
            followType:       type,
            content:          content,
            durationMinutes:  nil,
            visitedHouseIds:  [],
            customerFeedback: nil,
            nextFollowDate:   nil,
            nextFollowPlan:   nil,
            createdAt:        Date()
        )
    }
}
