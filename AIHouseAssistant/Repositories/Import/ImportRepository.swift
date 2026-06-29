import Foundation

/// 真实导入仓储 —— 预留后端实现（当前未接入服务器）
/// Release 环境注入；DEBUG 环境使用 MockImportRepository
final class ImportRepository: ImportRepositoryProtocol {

    private var records: [ImportRecord] = []

    func availableFiles(for type: ImportType) async throws -> [ImportFile] {
        // TODO: 接入后端文件上传与解析接口
        []
    }

    func runImport(type: ImportType, file: ImportFile, mapping: FieldMapping) async throws -> ImportResult {
        // TODO: 上传文件与映射，由后端执行导入
        throw APIError.businessError(code: -1, message: "导入服务尚未接入")
    }

    func history() async throws -> [ImportRecord] {
        records
    }

    func addRecord(_ record: ImportRecord) async {
        records.insert(record, at: 0)
    }

    func templates() async -> [ImportTemplate] {
        ImportTemplate.all
    }
}
