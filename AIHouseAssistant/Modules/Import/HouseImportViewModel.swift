import Foundation

/// 房源导入视图模型 —— 固定 type 为 .house
@MainActor
final class HouseImportViewModel: ImportFlowViewModel {
    init() { super.init(type: .house) }
}
