import SwiftUI

/// 房源高级筛选面板
struct HouseFilterSheet: View {

    let initial: HouseFilter
    var onApply: (HouseFilter) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - 草稿状态

    @State private var cities: Set<String> = []
    @State private var districts: Set<String> = []
    @State private var priceMin: Double = 0
    @State private var priceMax: Double = 0
    @State private var areaMin: Double = 0
    @State private var areaMax: Double = 0
    @State private var rooms: Set<Int> = []
    @State private var floors: Set<FloorPreference> = []
    @State private var decorations: Set<DecorationType> = []
    @State private var orientations: Set<OrientationType> = []
    @State private var propertyTypes: Set<PropertyType> = []
    @State private var tags: Set<HouseTag> = []

    private let roomOptions = [1, 2, 3, 4, 5]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    section("城市") {
                        chipGrid(HouseLocationOptions.cities, label: { $0 },
                                 isOn: { cities.contains($0) }, toggle: { toggle(&cities, $0) })
                    }
                    section("区域") {
                        chipGrid(HouseLocationOptions.districts, label: { $0 },
                                 isOn: { districts.contains($0) }, toggle: { toggle(&districts, $0) })
                    }
                    section("售价区间（万元）") {
                        rangeRow(min: $priceMin, max: $priceMax, unit: "万", step: 50, maxValue: 5000)
                    }
                    section("面积区间（㎡）") {
                        rangeRow(min: $areaMin, max: $areaMax, unit: "㎡", step: 10, maxValue: 1000)
                    }
                    section("户型") {
                        chipGrid(roomOptions, label: { "\($0) 室" },
                                 isOn: { rooms.contains($0) }, toggle: { toggle(&rooms, $0) })
                    }
                    section("楼层") {
                        chipGrid(FloorPreference.allCases.filter { $0 != .any },
                                 label: { $0.displayName },
                                 isOn: { floors.contains($0) }, toggle: { toggle(&floors, $0) })
                    }
                    section("装修") {
                        chipGrid(DecorationType.allCases, label: { $0.displayName },
                                 isOn: { decorations.contains($0) }, toggle: { toggle(&decorations, $0) })
                    }
                    section("朝向") {
                        chipGrid(OrientationType.allCases.filter { $0 != .any },
                                 label: { $0.displayName },
                                 isOn: { orientations.contains($0) }, toggle: { toggle(&orientations, $0) })
                    }
                    section("房屋类型") {
                        chipGrid(PropertyType.allCases, label: { $0.displayName },
                                 isOn: { propertyTypes.contains($0) }, toggle: { toggle(&propertyTypes, $0) })
                    }
                    section("标签") {
                        chipGrid(HouseTag.allCases, label: { $0.displayName },
                                 isOn: { tags.contains($0) }, toggle: { toggle(&tags, $0) })
                    }
                }
                .padding(AppSpacing.base)
            }
            .background(AppColor.backgroundAlt)
            .navigationTitle("高级筛选")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("重置", action: reset).foregroundStyle(AppColor.error)
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

    // MARK: - 区间行

    private func rangeRow(min: Binding<Double>, max: Binding<Double>,
                          unit: String, step: Double, maxValue: Double) -> some View {
        HStack(spacing: AppSpacing.md) {
            NumberField(label: "", unit: unit, value: min, minValue: 0, maxValue: maxValue, step: step)
            Text("—").foregroundStyle(AppColor.textLight)
            NumberField(label: "", unit: unit, value: max, minValue: 0, maxValue: maxValue, step: step)
        }
    }

    // MARK: - Section

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

    // MARK: - Chip 网格

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
                        .overlay(Capsule().stroke(selected ? .clear : AppColor.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle<T: Hashable>(_ set: inout Set<T>, _ value: T) {
        if set.contains(value) { set.remove(value) } else { set.insert(value) }
    }

    // MARK: - 初始化 / 重置 / 应用

    private func loadInitial() {
        cities = initial.cities
        districts = initial.districts
        priceMin = initial.priceMin ?? 0
        priceMax = initial.priceMax ?? 0
        areaMin = initial.areaMin ?? 0
        areaMax = initial.areaMax ?? 0
        rooms = initial.rooms
        floors = initial.floors
        decorations = initial.decorations
        orientations = initial.orientations
        propertyTypes = initial.propertyTypes
        tags = initial.tags
    }

    private func reset() {
        cities = []; districts = []
        priceMin = 0; priceMax = 0; areaMin = 0; areaMax = 0
        rooms = []; floors = []; decorations = []
        orientations = []; propertyTypes = []; tags = []
    }

    private func apply() {
        var filter = HouseFilter()
        filter.cities = cities
        filter.districts = districts
        filter.priceMin = priceMin > 0 ? priceMin : nil
        filter.priceMax = priceMax > 0 ? priceMax : nil
        filter.areaMin = areaMin > 0 ? areaMin : nil
        filter.areaMax = areaMax > 0 ? areaMax : nil
        filter.rooms = rooms
        filter.floors = floors
        filter.decorations = decorations
        filter.orientations = orientations
        filter.propertyTypes = propertyTypes
        filter.tags = tags
        onApply(filter)
        dismiss()
    }
}

// MARK: - Preview

#Preview("房源筛选") {
    HouseFilterSheet(initial: HouseFilter(), onApply: { _ in })
}
