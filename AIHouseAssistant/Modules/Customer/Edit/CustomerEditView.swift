import SwiftUI

/// 新增 / 编辑客户页
struct CustomerEditView: View {

    let customerId: String?

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel: CustomerEditViewModel

    init(customerId: String?) {
        self.customerId = customerId
        _viewModel = State(initialValue: CustomerEditViewModel(customerId: customerId))
    }

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
            await viewModel.onAppear(repository: container.customerRepository)
        }
    }

    // MARK: - 表单

    private var form: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                basicSection
                budgetSection
                areaSection
                layoutSection
                tagSection
                remarkSection
                saveButton
            }
            .padding(AppSpacing.base)
        }
    }

    // MARK: - 基本信息

    private var basicSection: some View {
        sectionGroup("基本信息") {
            AppTextField(label: "姓名 *", placeholder: "请输入客户姓名",
                         text: bind(\.draft.name), leadingIcon: "person",
                         errorMessage: viewModel.nameError)
            AppTextField(label: "手机号 *", placeholder: "请输入 11 位手机号",
                         text: bind(\.draft.phone), leadingIcon: "phone",
                         errorMessage: viewModel.phoneError, keyboardType: .phonePad)
            AppTextField(label: "微信", placeholder: "请输入微信号（选填）",
                         text: wechatBinding, leadingIcon: "message")

            labeledControl("性别") {
                Picker("性别", selection: bind(\.draft.gender)) {
                    ForEach(Gender.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    // MARK: - 预算

    private var budgetSection: some View {
        sectionGroup("购房预算（万元）") {
            HStack(spacing: AppSpacing.md) {
                NumberField(label: "下限", unit: "万", value: bind(\.draft.budgetMin),
                            minValue: 0, maxValue: 5000, step: 10)
                NumberField(label: "上限", unit: "万", value: bind(\.draft.budgetMax),
                            minValue: 0, maxValue: 5000, step: 10)
            }
        }
    }

    // MARK: - 面积 + 区域

    private var areaSection: some View {
        sectionGroup("面积与区域") {
            HStack(spacing: AppSpacing.md) {
                NumberField(label: "面积下限", unit: "㎡",
                            value: areaBinding(isMin: true),
                            minValue: 0, maxValue: 1000, step: 5)
                NumberField(label: "面积上限", unit: "㎡",
                            value: areaBinding(isMin: false),
                            minValue: 0, maxValue: 1000, step: 5)
            }
            labeledControl("意向区域") {
                CardView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: AppSpacing.sm)],
                              alignment: .leading, spacing: AppSpacing.sm) {
                        ForEach(CustomerAreaOptions.all, id: \.self) { area in
                            let isOn = viewModel.isAreaSelected(area)
                            Button { viewModel.toggleArea(area) } label: {
                                Text(area)
                                    .font(AppFont.captionMedium)
                                    .foregroundStyle(isOn ? .white : AppColor.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.sm)
                                    .background(isOn ? AppColor.primary : AppColor.surface)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 户型 / 装修 / 付款 / 状态

    private var layoutSection: some View {
        sectionGroup("户型与意向") {
            CardView {
                VStack(spacing: AppSpacing.base) {
                    Stepper(value: bind(\.roomsValue), in: 1...6) {
                        HStack {
                            Text("户型").font(AppFont.bodySmall).foregroundStyle(AppColor.textSecondary)
                            Spacer()
                            Text("\(viewModel.roomsValue) 室").font(AppFont.bodyMedium)
                                .foregroundStyle(AppColor.textPrimary)
                        }
                    }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("装修", selection: bind(\.decorationValue), options: DecorationType.allCases) { $0.displayName }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("付款方式", selection: bind(\.draft.paymentMethod), options: PaymentType.allCases) { $0.displayName }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("购房目的", selection: bind(\.draft.housePurpose), options: HousePurpose.allCases) { $0.displayName }
                    Divider().foregroundStyle(AppColor.divider)
                    menuRow("客户状态", selection: bind(\.draft.status), options: CustomerStatus.allCases) { $0.displayName }
                }
            }
        }
    }

    // MARK: - 标签

    private var tagSection: some View {
        sectionGroup("客户标签") {
            CardView {
                CustomerTagSelector(selected: bind(\.draft.tags))
            }
        }
    }

    // MARK: - 备注

    private var remarkSection: some View {
        sectionGroup("备注") {
            TextArea(label: "", placeholder: "记录客户的特殊需求、偏好等…",
                     text: remarkBinding, maxLength: 300)
        }
    }

    // MARK: - 保存按钮

    private var saveButton: some View {
        AppButton.primary(viewModel.isEditing ? "保存修改" : "创建客户",
                          icon: "checkmark",
                          isLoading: viewModel.isSaving) {
            Task {
                if await viewModel.save() {
                    ToastManager.shared.success(viewModel.isEditing ? "客户已更新" : "客户创建成功")
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

    @ViewBuilder
    private func labeledControl<Content: View>(_ title: String,
                                               @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppFont.captionMedium)
                .foregroundStyle(AppColor.textSecondary)
            content()
        }
    }

    /// 带菜单选择的行
    private func menuRow<T: Hashable>(_ title: String, selection: Binding<T>,
                                      options: [T], label: @escaping (T) -> String) -> some View {
        HStack {
            Text(title)
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Menu {
                Picker(title, selection: selection) {
                    ForEach(options, id: \.self) { Text(label($0)).tag($0) }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text(label(selection.wrappedValue))
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

    /// 通用引用类型 KeyPath 绑定
    private func bind<V>(_ keyPath: ReferenceWritableKeyPath<CustomerEditViewModel, V>) -> Binding<V> {
        Binding(get: { viewModel[keyPath: keyPath] },
                set: { viewModel[keyPath: keyPath] = $0 })
    }

    private var wechatBinding: Binding<String> {
        Binding(get: { viewModel.draft.wechat ?? "" },
                set: { viewModel.draft.wechat = $0.isEmpty ? nil : $0 })
    }

    private var remarkBinding: Binding<String> {
        Binding(get: { viewModel.draft.remark ?? "" },
                set: { viewModel.draft.remark = $0.isEmpty ? nil : $0 })
    }

    private func areaBinding(isMin: Bool) -> Binding<Double> {
        Binding(
            get: { (isMin ? viewModel.draft.expectedAreaMin : viewModel.draft.expectedAreaMax) ?? 0 },
            set: { newValue in
                let v = newValue == 0 ? nil : newValue
                if isMin { viewModel.draft.expectedAreaMin = v } else { viewModel.draft.expectedAreaMax = v }
            }
        )
    }
}

// MARK: - Preview

#Preview("新增客户") {
    NavigationStack {
        CustomerEditView(customerId: nil)
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
