import Foundation

/// 房源编辑视图模型 —— 同时支持「新增」与「编辑」
@MainActor
@Observable
final class HouseEditViewModel {

    // MARK: - 表单数据

    var draft: House

    // MARK: - 状态

    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var errorMessage: String?
    private(set) var titleError: String?
    private(set) var communityError: String?

    let isEditing: Bool
    private let houseId: String?
    private var repository: (any HouseRepositoryProtocol)?

    init(houseId: String?) {
        self.houseId = houseId
        self.isEditing = houseId != nil
        var base = House.new(title: "", community: "")
        // 新增模式给出合理默认地区（编辑模式将在 onAppear 覆盖）
        base.city = "上海"
        base.district = "浦东新区"
        self.draft = base
    }

    var navigationTitle: String { isEditing ? "编辑房源" : "新增房源" }

    // MARK: - 加载

    func onAppear(repository: any HouseRepositoryProtocol) async {
        self.repository = repository
        guard isEditing, let houseId else { return }
        isLoading = true
        do {
            draft = try await repository.detail(id: houseId)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - 图片（占位）

    /// 添加一张占位图片
    func addPlaceholderImage() {
        draft.images.append("ph-new-\(draft.images.count)")
    }

    /// 移除指定图片
    func removeImage(at index: Int) {
        guard draft.images.indices.contains(index) else { return }
        draft.images.remove(at: index)
    }

    // MARK: - 校验

    private func validate() -> Bool {
        titleError = nil
        communityError = nil
        errorMessage = nil
        var valid = true

        if draft.title.trimmingCharacters(in: .whitespaces).isEmpty {
            titleError = "请输入房源标题"
            valid = false
        }
        if draft.community.trimmingCharacters(in: .whitespaces).isEmpty {
            communityError = "请输入小区名称"
            valid = false
        }
        if draft.price <= 0 {
            errorMessage = "请输入有效的售价"
            valid = false
        }
        if draft.area <= 0 {
            errorMessage = "请输入有效的面积"
            valid = false
        }
        return valid
    }

    // MARK: - 保存

    func save() async -> Bool {
        guard let repository else { return false }
        guard validate() else { return false }

        // 单价缺省时按总价/面积自动计算
        if draft.unitPrice <= 0, draft.area > 0 {
            draft.unitPrice = (draft.price * 10000 / draft.area).rounded()
        }

        isSaving = true
        defer { isSaving = false }
        do {
            if isEditing {
                _ = try await repository.update(draft)
            } else {
                _ = try await repository.create(draft)
            }
            HouseEvents.shared.markChanged()
            return true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            return false
        }
    }
}
