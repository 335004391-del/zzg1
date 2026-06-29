import Foundation

/// 导入首页视图模型 —— 导入历史 + 模板下载
@MainActor
@Observable
final class ImportViewModel {

    private(set) var history: [ImportRecord] = []
    private(set) var templates: [ImportTemplate] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private var repository: (any ImportRepositoryProtocol)?
    private var hasLoaded = false

    func onAppear(repository: any ImportRepositoryProtocol) async {
        self.repository = repository
        guard !hasLoaded else { return }
        await load()
    }

    private func load() async {
        guard let repository else { return }
        isLoading = (history.isEmpty)
        errorMessage = nil
        do {
            templates = await repository.templates()
            history = try await repository.history()
            hasLoaded = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoading = false
    }

    /// 导入完成后刷新历史
    func reloadHistory() async {
        guard let repository, hasLoaded else { return }
        history = (try? await repository.history()) ?? history
    }

    /// 下载模板（Mock：提示已生成）
    func downloadTemplate(_ template: ImportTemplate) {
        ToastManager.shared.success("模板「\(template.name)」已生成")
    }
}
