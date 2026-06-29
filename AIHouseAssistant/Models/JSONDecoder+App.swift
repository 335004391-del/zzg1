import Foundation

/// 统一 JSON 解码器配置 — 自动处理 snake_case ↔ camelCase 转换及 ISO8601 日期
extension JSONDecoder {

    /// App 统一解码器实例
    static let app: JSONDecoder = {
        let decoder = JSONDecoder()
        // FastAPI 返回 snake_case，自动转 Swift camelCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // 统一使用 ISO8601 日期格式（后端返回 "2024-01-15T10:30:00Z"）
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

/// 统一 JSON 编码器配置 — 自动处理 camelCase → snake_case 及 ISO8601 日期
extension JSONEncoder {

    /// App 统一编码器实例
    static let app: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy  = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting     = .sortedKeys
        return encoder
    }()
}
