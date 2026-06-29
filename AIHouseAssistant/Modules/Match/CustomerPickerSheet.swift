import SwiftUI

/// 客户选择器 —— 匹配前选择目标客户
struct CustomerPickerSheet: View {

    let customers: [Customer]
    var onSelect: (Customer) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var keyword = ""

    private var filtered: [Customer] {
        guard !keyword.isEmpty else { return customers }
        return customers.filter {
            $0.name.contains(keyword) || $0.phone.contains(keyword)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.md) {
                SearchBar(placeholder: "搜索客户姓名 / 电话", text: $keyword)
                    .padding(.horizontal, AppSpacing.base)

                ScrollView {
                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(filtered) { customer in
                            row(customer)
                        }
                    }
                    .padding(.horizontal, AppSpacing.base)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .padding(.top, AppSpacing.sm)
            .background(AppColor.backgroundAlt)
            .navigationTitle("选择客户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private func row(_ customer: Customer) -> some View {
        Button {
            onSelect(customer)
            dismiss()
        } label: {
            CardView {
                HStack(spacing: AppSpacing.md) {
                    Text(customer.avatarText)
                        .font(AppFont.bodySemibold)
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(AppColor.primary.gradient)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(customer.name)
                            .font(AppFont.bodyMedium)
                            .foregroundStyle(AppColor.textPrimary)
                        Text("\(customer.budgetDescription) · \(customer.primaryArea)")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColor.textLight)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("客户选择器") {
    CustomerPickerSheet(customers: MockCustomerFactory.generate(count: 10), onSelect: { _ in })
}
