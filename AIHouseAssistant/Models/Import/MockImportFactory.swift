import Foundation

/// 导入数据 Mock 工厂 —— 生成可解析的示例文件（含少量脏数据以演示错误处理）
enum MockImportFactory {

    private static let surnames = ["张", "王", "李", "赵", "陈", "刘", "杨", "黄", "周", "吴"]
    private static let givenNames = ["伟", "敏", "静", "丽", "强", "磊", "军", "洋", "勇", "艳"]
    private static let purposes = ["自住", "投资", "改善", "养老", "婚房"]
    private static let communities = ["碧桂园天玺", "绿城玉兰花园", "万科翡翠公园", "保利天悦", "融创外滩壹号"]
    private static let orientations = ["南", "东南", "东", "西南", "北"]
    private static let decorations = ["精装修", "简装", "毛坯", "豪装"]

    // MARK: - 可选文件列表

    /// 某类型可选的示例文件（模拟文件选择器）
    static func files(for type: ImportType) -> [ImportFile] {
        switch type {
        case .customer:
            return [
                customerFile(name: "客户数据_2024.xlsx", format: .xlsx, count: 500),
                customerFile(name: "客户名单.csv",       format: .csv,  count: 128),
            ]
        case .house:
            return [
                houseFile(name: "房源清单_全量.xlsx", format: .xlsx, count: 1000),
                houseFile(name: "新增房源.csv",       format: .csv,  count: 206),
            ]
        }
    }

    // MARK: - 客户文件

    private static func customerFile(name: String, format: ImportFileFormat, count: Int) -> ImportFile {
        let headers = ["客户姓名", "联系电话", "微信号", "预算(万)", "意向区域",
                       "面积", "户型", "购房目的", "标签", "备注"]
        var rng = SeededGenerator(seed: UInt64(name.hashValue & 0x7FFFFFFF))
        let firstPhone = "13800000000"

        let rows: [[String]] = (0..<count).map { i in
            let name = surnames.randomElement(using: &rng)! + givenNames.randomElement(using: &rng)!
            var phone = "138" + String(format: "%08d", i)
            var budget = "\(Int.random(in: 80...600, using: &rng))"
            var area = CustomerAreaOptions.all.randomElement(using: &rng)!
            let size = "\(Int.random(in: 60...160, using: &rng))"
            let layout = "\(Int.random(in: 1...4, using: &rng))室"
            let purpose = purposes.randomElement(using: &rng)!
            let tags = ["学区", "地铁", "刚需", "改善"].randomElement(using: &rng)!
            let wechat = "wx_\(i)"

            // 注入脏数据用于演示错误处理
            switch i {
            case 49, 449: phone = ""                 // 手机号为空
            case 149:     budget = "面议"            // 预算格式错误
            case 249:     area = "火星区"            // 区域不存在
            case 349:     phone = firstPhone         // 重复客户（与第 0 行相同）
            default: break
            }
            if i == 0 { phone = firstPhone }

            return [name, phone, wechat, budget, area, size, layout, purpose, tags, "意向客户"]
        }

        return ImportFile(id: name, name: name, format: format, headers: headers, rows: rows)
    }

    // MARK: - 房源文件

    private static func houseFile(name: String, format: ImportFileFormat, count: Int) -> ImportFile {
        let headers = ["房源标题", "小区名称", "详细地址", "售价(万)", "建筑面积",
                       "户型", "楼层", "朝向", "装修", "标签", "图片链接"]
        var rng = SeededGenerator(seed: UInt64((name.hashValue &* 31) & 0x7FFFFFFF))

        let rows: [[String]] = (0..<count).map { i in
            let community = communities.randomElement(using: &rng)!
            var title = "\(community) | 精选好房 \(i)"
            var community2 = community
            var price = "\(Int.random(in: 100...900, using: &rng))"
            let size = "\(Int.random(in: 50...200, using: &rng))"
            let layout = "\(Int.random(in: 1...5, using: &rng))室"
            let floor = "\(Int.random(in: 1...33, using: &rng))层"
            let orientation = orientations.randomElement(using: &rng)!
            let decoration = decorations.randomElement(using: &rng)!
            let tags = ["学区", "地铁", "公园", "精装修"].randomElement(using: &rng)!

            switch i {
            case 99, 799: price = "电议"        // 价格格式错误
            case 299:     title = ""            // 标题为空
            case 599:     community2 = ""       // 小区为空
            default: break
            }

            return [title, community2, "\(community)路 \(i) 号", price, size,
                    layout, floor, orientation, decoration, tags, "https://img/\(i).jpg"]
        }

        return ImportFile(id: name, name: name, format: format, headers: headers, rows: rows)
    }
}
