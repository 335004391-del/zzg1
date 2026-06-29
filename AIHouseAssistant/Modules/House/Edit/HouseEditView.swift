import SwiftUI

/// 新增 / 编辑房源页
struct HouseEditView: View {

    let houseId: String?

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel: HouseEditViewModel

    init(houseId: String?) {
        self.houseId = houseId
        _viewModel = State(initialValue: HouseEditViewModel(houseId: houseId))
    }

    private let ownershipOptions = [40, 50, 70]

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            if viewModel.isLoading {
                AppLoadingView(message: "正在加载…")
            } else {
                form
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("取消") { nav.pop() }
            }
        }
        .task {
            await viewModel.onAppear(repository: container.houseRepository)
        }
    }

    // MARK: - 表单

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                basicSection
                locationSection
                priceSection
                layoutSection
                attributeSection
                propertySection
                tagSection
                imageSection
                descriptionSection
                saveButton
            }
            .padding(AppSpacing.base)
        }
    }

    // MARK: - 基本信息

    private var basicSection: some View {
        sectionGroup("基本信息") {
            AppTextField(label: "标题 *", placeholder: "如：碧桂园天玺 | 精装三房 | 地铁口",
                         text: bind(\.draft.title), leadingIcon: "textformat",
                         errorMessage: viewModel.titleError)
            AppTextField(label: "小区 *", placeholder: "请输入小区名称",
                         text: bind(\.draft.community), leadingIcon: "building.2",
                         errorMessage: viewModel.communityError)
            AppTextField(label: "地址", placeholder: "请输入详细地址",
                         text: bind(\.draft.address), leadingIcon: "mappin.and.ellipse")
        }
    }

    // MARK: - 位置

    private var locationSection: some View {
        sectionGroup("位置") {
            CardView {
                VStack(spacing: AppSpacing.base) {
                    menuRow("城市", selection: bind(\.draft.city), options: HouseLocationOptions.cities) { $0 }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("区域", selection: bind(\.draft.district), options: HouseLocationOptions.districts) { $0 }
                }
            }
        }
    }

    // MARK: - 价格

    private var priceSection: some View {
        sectionGroup("价格") {
            HStack(spacing: AppSpacing.md) {
                NumberField(label: "售价", unit: "万", value: bind(\.draft.price),
                            minValue: 0, maxValue: 100000, step: 10)
                NumberField(label: "单价", unit: "元/㎡", value: bind(\.draft.unitPrice),
                            minValue: 0, maxValue: 500000, step: 1000)
            }
        }
    }

    // MARK: - 面积与户型

    private var layoutSection: some View {
        sectionGroup("面积与户型") {
            NumberField(label: "建筑面积", unit: "㎡", value: bind(\.draft.area),
                        minValue: 0, maxValue: 2000, step: 5)
            CardView {
                VStack(spacing: AppSpacing.base) {
                    stepperRow("室", value: bind(\.draft.rooms), range: 1...8, suffix: "室")
                    Divider().foregroundStyle(AppColor.divider)
                    stepperRow("所在楼层", value: bind(\.draft.floor), range: 1...120, suffix: "层")
                    Divider().foregroundStyle(AppColor.divider)
                    stepperRow("总楼层", value: bind(\.draft.totalFloors), range: 1...120, suffix: "层")
                }
            }
        }
    }

    // MARK: - 房屋属性

    private var attributeSection: some View {
        sectionGroup("房屋属性") {
            CardView {
                VStack(spacing: AppSpacing.base) {
                    menuRow("朝向", selection: bind(\.draft.orientation),
                            options: OrientationType.allCases.filter { $0 != .any }) { $0.displayName }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("装修", selection: bind(\.draft.decoration), options: DecorationType.allCases) { $0.displayName }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("房屋类型", selection: bind(\.draft.propertyType), options: PropertyType.allCases) { $0.displayName }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("产权", selection: bind(\.draft.ownershipYears), options: ownershipOptions) { "\($0) 年" }
                    Divider().foregroundStyle(AppColor.divider)
                    stepperRow("建成年份", value: bind(\.draft.buildYear), range: 1990...2030, suffix: "年")
                }
            }
        }
    }

    // MARK: - 物业

    private var propertySection: some View {
        sectionGroup("物业与开发商") {
            AppTextField(label: "物业公司", placeholder: "请输入物业公司（选填）",
                         text: optionalBind(\.draft.propertyCompany), leadingIcon: "shield")
            AppTextField(label: "开发商", placeholder: "请输入开发商（选填）",
                         text: optionalBind(\.draft.developer), leadingIcon: "hammer")
        }
    }

    // MARK: - 标签

    private var tagSection: some View {
        sectionGroup("房源标签") {
            CardView {
                HouseTagSelector(selected: bind(\.draft.tags))
            }
        }
    }

    // MARK: - 图片（占位）

    private var imageSection: some View {
        sectionGroup("房源图片") {
            CardView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: AppSpacing.sm)],
                              spacing: AppSpacing.sm) {
                        ForEach(Array(viewModel.draft.images.enumerated()), id: \.offset) { index, _ in
                            imageThumb(index: index)
                        }
                        addImageButton
                    }
                    Text("图片上传为占位功能，后续接入真实图床")
                        .font(AppFont.caption2)
                        .foregroundStyle(AppColor.textLight)
                }
            }
        }
    }

    private func imageThumb(index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            HouseCoverPalette.gradient(seed: index)
                .frame(height: 72)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundStyle(.white.opacity(0.85))
                )
            Button {
                viewModel.removeImage(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .background(Circle().fill(.black.opacity(0.3)))
            }
            .buttonStyle(.plain)
            .padding(2)
        }
    }

    private var addImageButton: some View {
        Button {
            viewModel.addPlaceholderImage()
        } label: {
            RoundedRectangle(cornerRadius: AppRadius.sm)
                .stroke(AppColor.border, style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(height: 72)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColor.textLight)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 描述

    private var descriptionSection: some View {
        sectionGroup("房源描述") {
            TextArea(label: "", placeholder: "描述房源卖点、周边配套等…",
                     text: optionalBind(\.draft.description), maxLength: 500)
        }
    }

    // MARK: - 保存

    private var saveButton: some View {
        AppButton.primary(viewModel.isEditing ? "保存修改" : "创建房源",
                          icon: "checkmark", isLoading: viewModel.isSaving) {
            Task {
                if await viewModel.save() {
                    ToastManager.shared.success(viewModel.isEditing ? "房源已更新" : "房源创建成功")
                    nav.pop()
                } else if let msg = viewModel.errorMessage {
                    ToastManager.shared.error(msg)
                }
            }
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - 通用布局

    @ViewBuilder
    private func sectionGroup<Content: View>(_ title: String,
                                             @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            content()
        }
    }

    private func stepperRow(_ title: String, value: Binding<Int>,
                            range: ClosedRange<Int>, suffix: String) -> some View {
        Stepper(value: value, in: range) {
            HStack {
                Text(title).font(AppFont.bodySmall).foregroundStyle(AppColor.textSecondary)
                Spacer()
                Text("\(value.wrappedValue) \(suffix)").font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
    }

    private func menuRow<T: Hashable>(_ title: String, selection: Binding<T>,
                                      options: [T], label: @escaping (T) -> String) -> some View {
        HStack {
            Text(title).font(AppFont.bodySmall).foregroundStyle(AppColor.textSecondary)
            Spacer()
            Menu {
                Picker(title, selection: selection) {
                    ForEach(options, id: \.self) { Text(label($0)).tag($0) }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text(label(selection.wrappedValue).isEmpty ? "请选择" : label(selection.wrappedValue))
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.primary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11))
                        .foregroundStyle(AppColor.textLight)
                }
            }
        }
    }

    // MARK: - 绑定辅助

    private func bind<V>(_ keyPath: ReferenceWritableKeyPath<HouseEditViewModel, V>) -> Binding<V> {
        Binding(get: { viewModel[keyPath: keyPath] },
                set: { viewModel[keyPath: keyPath] = $0 })
    }

    private func optionalBind(_ keyPath: ReferenceWritableKeyPath<HouseEditViewModel, String?>) -> Binding<String> {
        Binding(get: { viewModel[keyPath: keyPath] ?? "" },
                set: { viewModel[keyPath: keyPath] = $0.isEmpty ? nil : $0 })
    }
}

// MARK: - Preview

#Preview("新增房源") {
    NavigationStack {
        HouseEditView(houseId: nil)
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
