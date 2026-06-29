import SwiftUI

/// 客户筛选面板 —— 状态 / 标签 / 区域 / 预算 / 成交概率 / 最后联系时间
struct CustomerFilterSheet: View {

    /// 初始筛选条件
    let initial: CustomerFilter
    /// 应用筛选
    var onApply: (CustomerFilter) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - 草稿状态

    @State private var statuses: Set<CustomerStatus> = []
    @State private var tags: Set<CustomerTag> = []
    @State private var areas: Set<String> = []
    @State private var budgetMin: Double = 0
    @State private var budgetMax: Double = 0
    @State private var minProbability: Double = 0
    @State private var contactDays: Int = 0   // 0 = 不限

    private let contactOptions: [(label: String, days: Int)] = [
        ("不限", 0), ("7 天内", 7), ("30 天内", 30), ("90 天内", 90),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    section("客户状态") {
                        chipGrid(CustomerStatus.allCases, label: { $0.displayName },
                                 isOn: { statuses.contains($0) }, toggle: toggleStatus)
                    }
                    section("客户标签") {
                        chipGrid(CustomerTag.allCases.filter { $0 != .any },
                                 label: { $0.displayName },
                                 isOn: { tags.contains($0) }, toggle: toggleTag)
                    }
                    section("意向区域") {
                        chipGrid(CustomerAreaOptions.all, label: { $0 },
                                 isOn: { areas.contains($0) }, toggle: toggleArea)
                    }
                    section("预算范围（万元）") {
                        HStack(spacing: AppSpacing.md) {
                            NumberField(label: "", unit: "万", value: $budgetMin,
                                        minValue: 0, maxValue: 5000, step: 50)
                            Text("—").foregroundStyle(AppColor.textLight)
                            NumberField(label: "", unit: "万", value: $budgetMax,
                                        minValue: 0, maxValue: 5000, step: 50)
                        }
                    }
                    section("最低成交概率") {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text(minProbability == 0 ? "不限" : "≥ \(Int(minProbability))%")
                                .font(AppFont.bodyMedium)
                                .foregroundStyle(AppColor.textPrimary)
                            Slider(value: $minProbability, in: 0...100, step: 5)
                                .tint(AppColor.primary)
                        }
                    }
                    section("最后联系时间") {
                        Picker("", selection: $contactDays) {
                            ForEach(contactOptions, id: \.days) { option in
                                Text(option.label).tag(option.days)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(AppSpacing.base)
            }
            .background(AppColor.backgroundAlt)
            .navigationTitle("筛选客户")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("重置", action: reset)
                        .foregroundStyle(AppColor.error)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                AppButton.primary("应用筛选", icon: "line.3.horizontal.decrease.circle") {
                    apply()
                }
                .padding(AppSpacing.base)
                .background(.ultraThinMaterial)
            }
        }
        .onAppear(perform: loadInitial)
    }

    // MARK: - 通用 Section

    @ViewBuilder
    private func section<Content: View>(_ title: String,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(title)
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            content()
        }
    }

    // MARK: - 自适应 Chip 网格

    private func chipGrid<T: Hashable>(_ items: [T],
                                       label: @escaping (T) -> String,
                                       isOn: @escaping (T) -> Bool,
                                       toggle: @escaping (T) -> Void) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: AppSpacing.sm)],
                  alignment: .leading, spacing: AppSpacing.sm) {
            ForEach(items, id: \.self) { item in
                let selected = isOn(item)
                Button { toggle(item) } label: {
                    Text(label(item))
                        .font(AppFont.captionMedium)
                        .foregroundStyle(selected ? .white : AppColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.sm)
                        .background(selected ? AppColor.primary : AppColor.card)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(selected ? .clear : AppColor.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 切换逻辑

    private func toggleStatus(_ s: CustomerStatus) {
        if statuses.contains(s) { statuses.remove(s) } else { statuses.insert(s) }
    }
    private func toggleTag(_ t: CustomerTag) {
        if tags.contains(t) { tags.remove(t) } else { tags.insert(t) }
    }
    private func toggleArea(_ a: String) {
        if areas.contains(a) { areas.remove(a) } else { areas.insert(a) }
    }

    // MARK: - 初始化 / 重置 / 应用

    private func loadInitial() {
        statuses = initial.statuses
        tags     = initial.tags
        areas    = initial.areas
        budgetMin = initial.budgetMin ?? 0
        budgetMax = initial.budgetMax ?? 0
        minProbability = Double(initial.minDealProbability ?? 0)
        contactDays = initial.lastContactWithinDays ?? 0
    }

    private func reset() {
        statuses = []; tags = []; areas = []
        budgetMin = 0; budgetMax = 0; minProbability = 0; contactDays = 0
    }

    private func apply() {
        var filter = CustomerFilter()
        filter.statuses = statuses
        filter.tags     = tags
        filter.areas    = areas
        filter.budgetMin = budgetMin > 0 ? budgetMin : nil
        filter.budgetMax = budgetMax > 0 ? budgetMax : nil
        filter.minDealProbability = minProbability > 0 ? Int(minProbability) : nil
        filter.lastContactWithinDays = contactDays > 0 ? contactDays : nil
        onApply(filter)
        dismiss()
    }
}

// MARK: - Preview

#Preview("筛选面板") {
    CustomerFilterSheet(initial: CustomerFilter(), onApply: { _ in })
}
