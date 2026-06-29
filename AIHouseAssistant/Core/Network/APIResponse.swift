import Foundation

/// 统一 API 响应包装结构 — 对应后端 FastAPI 统一返回格式
/// 后端返回格式：{ "code": 0, "message": "ok", "data": {...}, "timestamp": 1700000000, "request_id": "xxx" }
struct APIResponse<T: Decodable>: Decodable {

    /// 业务状态码（0 = 成功）
    var code: Int
    /// 提示信息
    var message: String
    /// 实际数据（可能为 nil，如删除操作）
    var data: T?
    /// 服务器时间戳
    var timestamp: Int?
    /// 请求追踪 ID
    var requestId: String?

    /// 是否成功
    var isSuccess: Bool { code == 0 }
}

// MARK: - 分页请求

/// 统一分页请求参数
struct PageRequest: Codable {
    /// 页码（从 1 开始）
    var page: Int
    /// 每页数量
    var pageSize: Int
    /// 搜索关键词（可选）
    var keyword: String?
    /// 排序字段
    var sortBy: String?
    /// 是否升序
    var ascending: Bool

    init(page: Int = 1, pageSize: Int = AppConfig.defaultPageSize,
         keyword: String? = nil, sortBy: String? = nil, ascending: Bool = false) {
        self.page      = page
        self.pageSize  = pageSize
        self.keyword   = keyword
        self.sortBy    = sortBy
        self.ascending = ascending
    }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "page",      value: "\(page)"),
            .init(name: "page_size", value: "\(pageSize)"),
            .init(name: "ascending", value: "\(ascending)"),
        ]
        if let kw = keyword   { items.append(.init(name: "keyword", value: kw)) }
        if let sort = sortBy  { items.append(.init(name: "sort_by", value: sort)) }
        return items
    }
}

// MARK: - 分页响应

/// 统一分页响应结构
struct PageResponse<T: Codable>: Codable {
    /// 数据列表
    var items: [T]
    /// 总记录数
    var total: Int
    /// 当前页
    var page: Int
    /// 每页数量
    var pageSize: Int
    /// 是否还有更多
    var hasMore: Bool

    /// 总页数
    var totalPages: Int { Int(ceil(Double(total) / Double(pageSize))) }
}
