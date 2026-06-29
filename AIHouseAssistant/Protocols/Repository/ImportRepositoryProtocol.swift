import Foundation

/// 数据导入仓储协议 —— 文件读取 / 校验导入 / 历史 / 模板
protocol ImportRepositoryProtocol {

    /// 获取某类型可导入的文件列表（模拟文件选择）
    func availableFiles(for type: ImportType) async throws -> [ImportFile]

    /// 执行导入（按映射校验全部数据，返回成功/失败统计）
    func runImport(type: ImportType, file: ImportFile, mapping: FieldMapping) async throws -> ImportResult

    /// 获取导入历史
    func history() async throws -> [ImportRecord]

    /// 追加一条导入历史
    func addRecord(_ record: ImportRecord) async

    /// 获取可下载模板
    func templates() async -> [ImportTemplate]
}
