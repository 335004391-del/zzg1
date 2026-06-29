import Foundation

/// 客户编辑视图模型 —— 同时支持「新增」与「编辑」
@MainActor
@Observable
final class CustomerEditViewModel {

    // MARK: - 表单数据

    /// 编辑中的客户草稿
    var draft: Customer
    /// 户型（单值，保存时映射为数组）
    var roomsValue: Int
    /// 装修（单值，保存时映射为数组）
    var decorationValue: DecorationType

    // MARK: - 状态

    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    /// 字段级错误
    private(set) var nameError: String?
    private(set) var phoneError: String?

    /// 是否为编辑模式
    let isEditing: Bool
    private let customerId: String?
    private var repository: (any CustomerRepositoryProtocol)?

    // MARK: - 初始化

    init(customerId: String?) {
        self.customerId = customerId
        self.isEditing  = customerId != nil
        let base = Customer.new(name: "", phone: "")
        self.draft           = base
        self.roomsValue      = base.expectedRooms.first ?? 3
        self.decorationValue = base.expectedDecoration.first ?? .fine
    }

    var navigationTitle: String { isEditing ? "编辑客户" : "新增客户" }

    // MARK: - 加载（编辑模式）

    func onAppear(repository: any CustomerRepositoryProtocol) async {
        self.repository = repository
        guard isEditing, let customerId else { return }
        isLoading = true
        do {
            let existing = try await repository.detail(id: customerId)
            draft           = existing
            roomsValue      = existing.expectedRooms.first ?? 3
            decorationValue = existing.expectedDecoration.first ?? .fine
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - 区域多选

    func toggleArea(_ area: String) {
        if let index = draft.preferredArea.firstIndex(of: area) {
            draft.preferredArea.remove(at: index)
        } else {
            draft.preferredArea.append(area)
        }
    }

    func isAreaSelected(_ area: String) -> Bool {
        draft.preferredArea.contains(area)
    }

    // MARK: - 校验

    private func validate() -> Bool {
        nameError = nil
        phoneError = nil
        var valid = true

        let name = draft.name.trimmingCharacters(in: .whitespaces)
        if name.isEmpty {
            nameError = "请输入客户姓名"
            valid = false
        }

        let phone = draft.phone.trimmingCharacters(in: .whitespaces)
        if !isValidPhone(phone) {
            phoneError = "请输入有效的 11 位手机号"
            valid = false
        }

        if draft.budgetMax < draft.budgetMin {
            errorMessage = "预算上限不能低于下限"
            valid = false
        }
        return valid
    }

    private func isValidPhone(_ phone: String) -> Bool {
        phone.count == 11 && phone.first == "1" && phone.allSatisfy { $0.isNumber }
    }

    // MARK: - 保存

    func save() async -> Bool {
        guard let repository else { return false }
        errorMessage = nil
        guard validate() else { return false }

        // 应用单值字段
        draft.expectedRooms      = [roomsValue]
        draft.expectedDecoration = [decorationValue]
        draft.schoolRequirement  = draft.tags.contains(.school)
        draft.subwayRequirement  = draft.tags.contains(.subway)

        isSaving = true
        defer { isSaving = false }
        do {
            if isEditing {
                _ = try await repository.update(draft)
            } else {
                _ = try await repository.create(draft)
            }
            CustomerEvents.shared.markChanged()
            return true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }
}
