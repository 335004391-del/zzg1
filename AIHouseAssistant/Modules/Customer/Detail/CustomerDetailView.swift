import SwiftUI

/// 客户详情页
struct CustomerDetailView: View {

    let customerId: String

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel: CustomerDetailViewModel
    @State private var deleteConfig: ConfirmDialogConfig?

    init(customerId: String) {
        self.customerId = customerId
        _viewModel = State(initialValue: CustomerDetailViewModel(customerId: customerId))
    }

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            content
        }
        .navigationTitle(viewModel.customer?.name ?? "客户详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.onAppear(repository: container.customerRepository)
        }
        .onChange(of: CustomerEvents.shared.version) {
            Task { await viewModel.reloadAfterExternalChange() }
        }
        .confirmDialog(config: $deleteConfig)
    }

    // MARK: - 内容

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            AppLoadingView(message: "正在加载客户…")
        } else if let message = viewModel.errorMessage, viewModel.customer == nil {
            ErrorStateView(message: message) {
                Task { await viewModel.reloadAfterExternalChange() }
            }
        } else if let customer = viewModel.customer {
            detailScroll(customer)
        }
    }

    private func detailScroll(_ customer: Customer) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                headerCard(customer)
                contactSection(customer)
                requirementSection(customer)
                tagSection(customer)
                CustomerAIProfileCard(
                    points: viewModel.aiPoints,
                    dealProbability: customer.dealProbability,
                    aiScore: customer.aiScore
                )
                followSection
                recommendPlaceholder
            }
            .padding(AppSpacing.base)
        }
    }

    // MARK: - 头部

    private func headerCard(_ customer: Customer) -> some View {
        CardView {
            VStack(spacing: AppSpacing.md) {
                Text(customer.avatarText)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(AppColor.primary.gradient)
                    .clipShape(Circle())

                VStack(spacing: AppSpacing.xs) {
                    Text(customer.name)
                        .font(AppFont.title)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(customer.customerCode)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textLight)
                }

                HStack(spacing: AppSpacing.sm) {
                    TagView(text: customer.gender.displayName, style: .neutral, size: .small)
                    TagView(text: customer.status.displayName,
                            style: customer.status.tagStyle, size: .small)
                    TagView(text: "成交 \(customer.dealProbability)%",
                            style: .success, size: .small)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - 联系方式

    private func contactSection(_ customer: Customer) -> some View {
        SectionCard(title: "联系方式", icon: "person.crop.circle") {
            VStack(spacing: AppSpacing.md) {
                keyValueRow(icon: "phone.fill", label: "手机号", value: customer.phone,
                            trailingIcon: "phone.circle.fill") {
                    ToastManager.shared.info("拨打 \(customer.phone)")
                }
                keyValueRow(icon: "message.fill", label: "微信",
                            value: customer.wechat ?? "未填写")
                keyValueRow(icon: "building.2.fill", label: "公司",
                            value: customer.company ?? "未填写")
                keyValueRow(icon: "briefcase.fill", label: "职业",
                            value: customer.occupation ?? "未填写")
            }
        }
    }

    // MARK: - 购房需求

    private func requirementSection(_ customer: Customer) -> some View {
        SectionCard(title: "购房需求", icon: "list.bullet.clipboard") {
            VStack(spacing: AppSpacing.md) {
                keyValueRow(icon: "yensign.circle.fill", label: "预算",
                            value: customer.budgetDescription)
                keyValueRow(icon: "ruler.fill", label: "面积",
                            value: customer.areaDescription)
                keyValueRow(icon: "mappin.and.ellipse", label: "区域",
                            value: customer.preferredArea.isEmpty ? "不限" : customer.preferredArea.joined(separator: "、"))
                keyValueRow(icon: "square.split.bottomrightquarter", label: "户型",
                            value: customer.roomsDescription)
                keyValueRow(icon: "paintbrush.fill", label: "装修",
                            value: customer.expectedDecoration.first?.displayName ?? "不限")
                keyValueRow(icon: "creditcard.fill", label: "付款方式",
                            value: customer.paymentMethod.displayName)
            }
        }
    }

    // MARK: - 标签

    private func tagSection(_ customer: Customer) -> some View {
        SectionCard(title: "客户标签", icon: "tag") {
            if customer.tags.isEmpty {
                Text("暂无标签")
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: AppSpacing.sm)],
                          alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(customer.tags) { tag in
                        TagView(text: tag.displayName, style: tag.tagStyle,
                                size: .small, icon: tag.icon)
                    }
                }
            }
        }
    }

    // MARK: - 跟进记录

    private var followSection: some View {
        SectionCard(title: "跟进记录", subtitle: "共 \(viewModel.follows.count) 条",
                    icon: "clock.arrow.circlepath") {
            if viewModel.follows.isEmpty {
                Text("暂无跟进记录")
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textLight)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.follows.enumerated()), id: \.element.id) { index, record in
                        FollowRecordRow(record: record)
                        if index < viewModel.follows.count - 1 {
                            Divider().foregroundStyle(AppColor.divider)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 推荐房源（占位）

    private var recommendPlaceholder: some View {
        SectionCard(title: "推荐房源", icon: "house.fill") {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColor.aiPurple)
                Text("AI 智能房源推荐即将上线")
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textSecondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 通用键值行

    private func keyValueRow(icon: String, label: String, value: String,
                             trailingIcon: String? = nil,
                             action: (() -> Void)? = nil) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppColor.primary)
                .frame(width: 22)
            Text(label)
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
            if let trailingIcon, let action {
                Button(action: action) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 20))
                        .foregroundStyle(AppColor.success)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 工具栏

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await viewModel.toggleFavorite() }
            } label: {
                Image(systemName: (viewModel.customer?.isFavorite ?? false) ? "star.fill" : "star")
                    .foregroundStyle((viewModel.customer?.isFavorite ?? false) ? AppColor.warning : AppColor.textSecondary)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    nav.push(.customerEdit(customerId: customerId))
                } label: {
                    Label("编辑客户", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    requestDelete()
                } label: {
                    Label("删除客户", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    private func requestDelete() {
        guard let customer = viewModel.customer else { return }
        deleteConfig = .destructive(
            title: "删除客户",
            message: "确认删除「\(customer.name)」吗？\n此操作不可撤销。",
            onConfirm: {
                Task {
                    if await viewModel.delete() {
                        ToastManager.shared.success("已删除「\(customer.name)」")
                        nav.pop()
                    }
                }
            }
        )
    }
}

// MARK: - Preview

#Preview("客户详情") {
    NavigationStack {
        CustomerDetailView(customerId: "mock-1")
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
