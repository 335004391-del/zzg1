import Foundation

/// 导入类型 —— 客户 / 房源
enum ImportType: String, Hashable, Identifiable, CaseIterable {
    case customer
    case house

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .customer: return "客户"
        case .house:    return "房源"
        }
    }

    var icon: String {
        switch self {
        case .customer: return "person.2.fill"
        case .house:    return "building.2.fill"
        }
    }

    /// 目标字段架构（系统字段）
    var fields: [ImportField] {
        switch self {
        case .customer:
            return [
                .init(key: "name",    title: "姓名",     required: true,  synonyms: ["姓名", "名字", "客户", "name"]),
                .init(key: "phone",   title: "电话",     required: true,  synonyms: ["电话", "手机", "联系", "号码", "phone"]),
                .init(key: "wechat",  title: "微信",     required: false, synonyms: ["微信", "wechat", "wx"]),
                .init(key: "budget",  title: "预算",     required: false, synonyms: ["预算", "价位", "budget"]),
                .init(key: "area",    title: "区域",     required: false, synonyms: ["区域", "意向", "地区", "板块", "area"]),
                .init(key: "size",    title: "面积",     required: false, synonyms: ["面积", "平米", "size", "㎡"]),
                .init(key: "layout",  title: "户型",     required: false, synonyms: ["户型", "房型", "室", "layout"]),
                .init(key: "purpose", title: "购房目的", required: false, synonyms: ["目的", "用途", "purpose"]),
                .init(key: "tags",    title: "标签",     required: false, synonyms: ["标签", "tag"]),
                .init(key: "remark",  title: "备注",     required: false, synonyms: ["备注", "说明", "remark"]),
            ]
        case .house:
            return [
                .init(key: "title",       title: "标题",     required: true,  synonyms: ["标题", "title", "房源"]),
                .init(key: "community",   title: "小区",     required: true,  synonyms: ["小区", "楼盘", "社区", "community"]),
                .init(key: "address",     title: "地址",     required: false, synonyms: ["地址", "位置", "address"]),
                .init(key: "price",       title: "价格",     required: false, synonyms: ["价格", "售价", "总价", "price"]),
                .init(key: "size",        title: "面积",     required: false, synonyms: ["面积", "平米", "建筑面积", "size"]),
                .init(key: "layout",      title: "户型",     required: false, synonyms: ["户型", "房型", "室"]),
                .init(key: "floor",       title: "楼层",     required: false, synonyms: ["楼层", "层", "floor"]),
                .init(key: "orientation", title: "朝向",     required: false, synonyms: ["朝向", "向", "orientation"]),
                .init(key: "decoration",  title: "装修",     required: false, synonyms: ["装修", "decoration"]),
                .init(key: "tags",        title: "标签",     required: false, synonyms: ["标签", "卖点", "tag"]),
                .init(key: "images",      title: "图片",     required: false, synonyms: ["图片", "图", "照片", "链接", "image"]),
            ]
        }
    }

    /// 自动字段匹配 —— 将 Excel 表头映射到系统字段
    func autoMatch(headers: [String]) -> FieldMapping {
        var mapping: FieldMapping = [:]
        for field in fields {
            if let matched = headers.first(where: { header in
                field.synonyms.contains { header.localizedCaseInsensitiveContains($0) }
            }) {
                mapping[field.key] = matched
            }
        }
        return mapping
    }
}

/// 系统目标字段
struct ImportField: Identifiable, Hashable {
    let key: String
    let title: String
    let required: Bool
    let synonyms: [String]
    var id: String { key }
}

/// 字段映射：系统字段 key -> Excel 表头
typealias FieldMapping = [String: String]

// MARK: - 文件

/// 文件格式
enum ImportFileFormat: String, Hashable {
    case xlsx, xls, csv, numbers, googleSheet

    var displayName: String {
        switch self {
        case .xlsx:        return "Excel (.xlsx)"
        case .xls:         return "Excel (.xls)"
        case .csv:         return "CSV (.csv)"
        case .numbers:     return "Numbers"
        case .googleSheet: return "Google Sheet"
        }
    }

    var icon: String {
        switch self {
        case .xlsx, .xls: return "tablecells.fill"
        case .csv:        return "doc.text.fill"
        case .numbers:    return "tablecells"
        case .googleSheet: return "doc.richtext.fill"
        }
    }

    /// 当前是否支持（numbers / googleSheet 预留）
    var isSupported: Bool {
        switch self {
        case .xlsx, .xls, .csv: return true
        case .numbers, .googleSheet: return false
        }
    }
}

/// 导入文件（Mock 解析结果）
struct ImportFile: Identifiable, Hashable {
    let id: String
    let name: String
    let format: ImportFileFormat
    /// 表头
    let headers: [String]
    /// 原始数据行
    let rows: [[String]]

    var rowCount: Int { rows.count }

    /// 取某行某系统字段的值
    func value(forField key: String, row: [String], mapping: FieldMapping) -> String {
        guard let header = mapping[key],
              let idx = headers.firstIndex(of: header),
              row.indices.contains(idx) else { return "" }
        return row[idx]
    }
}

// MARK: - 预览

/// 预览行（可编辑 / 删除）
struct ImportPreviewRow: Identifiable {
    let id: String
    /// 系统字段 key -> 值
    var values: [String: String]
}

// MARK: - 结果

/// 单行导入错误
struct ImportRowError: Identifiable, Hashable {
    let id = UUID()
    let row: Int
    let reason: String
}

/// 导入结果
struct ImportResult {
    let total: Int
    let success: Int
    let failed: Int
    let errors: [ImportRowError]
    let duration: TimeInterval

    var successRate: Double {
        total == 0 ? 0 : Double(success) / Double(total)
    }
}

// MARK: - 历史

/// 导入历史记录
struct ImportRecord: Identifiable, Hashable {
    let id: String
    let fileName: String
    let type: ImportType
    let importedAt: Date
    let operatorName: String
    let successCount: Int
    let failedCount: Int
    let duration: TimeInterval

    var totalCount: Int { successCount + failedCount }
    var isAllSuccess: Bool { failedCount == 0 }
}

// MARK: - 模板

/// 导入模板
struct ImportTemplate: Identifiable, Hashable {
    let id: String
    let type: ImportType
    let format: ImportFileFormat
    let name: String

    /// 全部可下载模板（客户/房源 × CSV/Excel）
    static let all: [ImportTemplate] = [
        .init(id: "tpl-c-xlsx", type: .customer, format: .xlsx, name: "客户导入模板.xlsx"),
        .init(id: "tpl-c-csv",  type: .customer, format: .csv,  name: "客户导入模板.csv"),
        .init(id: "tpl-h-xlsx", type: .house,    format: .xlsx, name: "房源导入模板.xlsx"),
        .init(id: "tpl-h-csv",  type: .house,    format: .csv,  name: "房源导入模板.csv"),
    ]
}

// MARK: - 流程步骤

/// 导入流程步骤
enum ImportStep: Int, CaseIterable, Identifiable {
    case selectFile  // 选择文件
    case mapping     // 字段映射
    case preview     // 数据预览
    case importing   // 导入中
    case result      // 导入结果

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .selectFile: return "选择文件"
        case .mapping:    return "字段映射"
        case .preview:    return "数据预览"
        case .importing:  return "正在导入"
        case .result:     return "导入完成"
        }
    }

    /// 进度条用的步骤序号（导入中与结果合并展示）
    static var indicatorSteps: [ImportStep] { [.selectFile, .mapping, .preview, .result] }
}
