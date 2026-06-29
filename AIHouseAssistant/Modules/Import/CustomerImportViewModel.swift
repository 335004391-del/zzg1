import Foundation

/// 客户导入视图模型 —— 固定 type 为 .customer
@MainActor
final class CustomerImportViewModel: ImportFlowViewModel {
    init() { super.init(type: .customer) }
}
