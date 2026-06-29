import Foundation

/// Mock 导入仓储 —— 内存态实现，模拟文件解析、数据校验与历史记录
actor MockImportRepository: ImportRepositoryProtocol {

    // MARK: - 历史存储（预置两条）

    private var records: [ImportRecord] = [
        ImportRecord(id: "rec-1", fileName: "客户.xlsx", type: .customer,
                     importedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                     operatorName: "张经理", successCount: 300, failedCount: 0, duration: 4.2),
        ImportRecord(id: "rec-2", fileName: "房源.xlsx", type: .house,
                     importedAt: Date(),
                     operatorName: "张经理", successCount: 126, failedCount: 3, duration: 6.8),
    ]

    // MARK: - 文件

    func availableFiles(for type: ImportType) async throws -> [ImportFile] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return MockImportFactory.files(for: type)
    }

    // MARK: - 导入校验

    func runImport(type: ImportType, file: ImportFile, mapping: FieldMapping) async throws -> ImportResult {
        let start = Date()
        try await Task.sleep(nanoseconds: 600_000_000)

        var success = 0
        var errors: [ImportRowError] = []
        var seenKeys = Set<String>()

        for (index, row) in file.rows.enumerated() {
            if let reason = validate(type: type, file: file, row: row,
                                     mapping: mapping, seenKeys: &seenKeys) {
                errors.append(ImportRowError(row: index + 1, reason: reason))
            } else {
                success += 1
            }
        }

        // 模拟一个合理的耗时（与数据量相关）
        let duration = max(Date().timeIntervalSince(start), Double(file.rowCount) / 250.0)
        return ImportResult(total: file.rowCount, success: success,
                            failed: errors.count, errors: errors, duration: duration)
    }

    /// 单行校验，返回失败原因（nil 表示通过）
    private func validate(type: ImportType, file: ImportFile, row: [String],
                          mapping: FieldMapping, seenKeys: inout Set<String>) -> String? {
        func value(_ key: String) -> String {
            file.value(forField: key, row: row, mapping: mapping).trimmingCharacters(in: .whitespaces)
        }

        switch type {
        case .customer:
            let phone = value("phone")
            if phone.isEmpty { return "手机号为空" }
            if seenKeys.contains(phone) { return "重复客户" }
            let budget = value("budget")
            if !budget.isEmpty, Double(budget) == nil { return "预算格式错误" }
            let area = value("area")
            if !area.isEmpty, !CustomerAreaOptions.all.contains(area) { return "区域不存在" }
            seenKeys.insert(phone)
            return nil

        case .house:
            if value("title").isEmpty { return "标题为空" }
            if value("community").isEmpty { return "小区为空" }
            let price = value("price")
            if !price.isEmpty, Double(price) == nil { return "价格格式错误" }
            return nil
        }
    }

    // MARK: - 历史

    func history() async throws -> [ImportRecord] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return records.sorted { $0.importedAt > $1.importedAt }
    }

    func addRecord(_ record: ImportRecord) async {
        records.insert(record, at: 0)
    }

    // MARK: - 模板

    func templates() async -> [ImportTemplate] {
        ImportTemplate.all
    }
}
