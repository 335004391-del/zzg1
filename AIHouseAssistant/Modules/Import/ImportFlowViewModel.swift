import Foundation

/// 导入流程视图模型 —— 驱动「选择文件 → 字段映射 → 预览 → 导入 → 结果」全流程
/// 客户与房源共用此逻辑，由 type 区分（CustomerImportViewModel / HouseImportViewModel 为其子类）
@MainActor
@Observable
class ImportFlowViewModel {

    // MARK: - 配置

    let type: ImportType

    // MARK: - 流程状态

    var step: ImportStep = .selectFile

    // 文件选择
    private(set) var availableFiles: [ImportFile] = []
    private(set) var isLoadingFiles = false
    private(set) var selectedFile: ImportFile?

    // 字段映射
    var mapping: FieldMapping = [:]

    // 预览
    private(set) var previewRows: [ImportPreviewRow] = []

    // 导入进度
    private(set) var progress: Double = 0

    // 结果
    private(set) var result: ImportResult?

    private(set) var errorMessage: String?

    // MARK: - 依赖

    private var repository: (any ImportRepositoryProtocol)?

    init(type: ImportType) {
        self.type = type
    }

    // MARK: - 计算属性

    /// 系统字段架构
    var fields: [ImportField] { type.fields }

    /// 可选 Excel 表头
    var headerOptions: [String] { selectedFile?.headers ?? [] }

    /// 未映射的必填字段
    var unmappedRequiredFields: [ImportField] {
        fields.filter { $0.required && (mapping[$0.key]?.isEmpty ?? true) }
    }

    /// 是否可进入预览（必填字段均已映射）
    var canProceedToPreview: Bool { unmappedRequiredFields.isEmpty }

    /// 总数据量
    var totalRowCount: Int { selectedFile?.rowCount ?? 0 }

    // MARK: - 生命周期

    func onAppear(repository: any ImportRepositoryProtocol) async {
        self.repository = repository
        if availableFiles.isEmpty { await loadFiles() }
    }

    func loadFiles() async {
        guard let repository else { return }
        isLoadingFiles = true
        errorMessage = nil
        do {
            availableFiles = try await repository.availableFiles(for: type)
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        isLoadingFiles = false
    }

    // MARK: - 步骤推进

    /// 选择文件并自动匹配字段
    func selectFile(_ file: ImportFile) {
        selectedFile = file
        mapping = type.autoMatch(headers: file.headers)
        step = .mapping
    }

    /// 修改某字段的映射（header 为 nil 表示不导入）
    func setMapping(field key: String, header: String?) {
        if let header, !header.isEmpty {
            mapping[key] = header
        } else {
            mapping.removeValue(forKey: key)
        }
    }

    /// 确认映射，生成预览（前 20 条）
    func confirmMapping() {
        guard let file = selectedFile else { return }
        previewRows = file.rows.prefix(20).enumerated().map { index, row in
            var values: [String: String] = [:]
            for field in fields {
                values[field.key] = file.value(forField: field.key, row: row, mapping: mapping)
            }
            return ImportPreviewRow(id: "row-\(index)", values: values)
        }
        step = .preview
    }

    /// 删除预览行
    func deletePreviewRow(_ id: String) {
        previewRows.removeAll { $0.id == id }
    }

    /// 修改预览行某字段
    func updatePreview(rowId: String, fieldKey: String, value: String) {
        guard let index = previewRows.firstIndex(where: { $0.id == rowId }) else { return }
        previewRows[index].values[fieldKey] = value
    }

    /// 开始导入（模拟进度动画 + 校验全部数据）
    func startImport() async {
        guard let repository, let file = selectedFile else { return }
        step = .importing
        progress = 0
        errorMessage = nil

        // 模拟进度动画
        let ticks = 30
        for tick in 1...ticks {
            try? await Task.sleep(nanoseconds: 50_000_000)
            progress = Double(tick) / Double(ticks) * 0.9
        }

        do {
            let res = try await repository.runImport(type: type, file: file, mapping: mapping)
            progress = 1
            result = res
            // 写入导入历史
            let record = ImportRecord(
                id: UUID().uuidString,
                fileName: file.name,
                type: type,
                importedAt: Date(),
                operatorName: "张经理",
                successCount: res.success,
                failedCount: res.failed,
                duration: res.duration
            )
            await repository.addRecord(record)
            ImportEvents.shared.markChanged()
            step = .result
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            step = .preview
        }
    }

    // MARK: - 返回 / 重置

    func backToMapping() { step = .mapping }
    func backToSelect()  { step = .selectFile }

    /// 再次导入（重置流程）
    func reset() {
        step = .selectFile
        selectedFile = nil
        mapping = [:]
        previewRows = []
        progress = 0
        result = nil
        errorMessage = nil
    }

    /// 导出错误报告（Mock）
    func exportErrorReport() {
        ToastManager.shared.success("错误报告 ImportError.xlsx 已生成")
    }
}
