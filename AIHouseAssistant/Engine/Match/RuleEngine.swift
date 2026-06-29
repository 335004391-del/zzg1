import Foundation

/// 规则引擎 —— 匹配第一层硬过滤
/// 负责：在评分前剔除明显不符合的房源，降低评分计算量
/// 规则（第一版）：
///   1. 房源必须在售
///   2. 预算差距超过 60%（房价 > 预算上限 ×1.6）直接过滤
struct RuleEngine {

    /// 对房源做第一层过滤
    func filter(customer: Customer, houses: [House]) -> [House] {
        houses.filter { house in
            passesStatus(house) && passesBudget(customer: customer, house: house)
        }
    }

    // MARK: - 单项规则

    /// 仅推荐在售房源
    private func passesStatus(_ house: House) -> Bool {
        house.status == .available
    }

    /// 预算硬过滤：超出预算上限 60% 直接淘汰
    private func passesBudget(customer: Customer, house: House) -> Bool {
        guard customer.budgetMax > 0 else { return true }
        return house.price <= customer.budgetMax * 1.6
    }
}
