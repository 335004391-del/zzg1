import Foundation

extension String {

    /// 是否为空或仅含空白字符
    var isBlank: Bool { trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    /// 是否为有效邮箱格式
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    /// 是否为有效手机号（中国大陆）
    var isValidChinesePhone: Bool {
        let regex = "^1[3-9]\\d{9}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
}
