import SwiftUI

/// 房源详情页
struct HouseDetailView: View {

    let houseId: String

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel: HouseDetailViewModel
    @State private var deleteConfig: ConfirmDialogConfig?

    init(houseId: String) {
        self.houseId = houseId
        _viewModel = State(initialValue: HouseDetailViewModel(houseId: houseId))
    }

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            content
        }
        .navigationTitle(viewModel.house?.community ?? "房源详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .task {
            await viewModel.onAppear(repository: container.houseRepository)
        }
        .onChange(of: HouseEvents.shared.version) {
            Task { await viewModel.reloadAfterExternalChange() }
        }
        .confirmDialog(config: $deleteConfig)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            AppLoadingView(message: "正在加载房源…")
        } else if let message = viewModel.errorMessage, viewModel.house == nil {
            ErrorStateView(message: message) {
                Task { await viewModel.reloadAfterExternalChange() }
            }
        } else if let house = viewModel.house {
            detailScroll(house)
        }
    }

    private func detailScroll(_ house: House) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // 图片轮播（全幅）
                HouseImageCarousel(images: house.images, coverSeed: house.coverSeed) { index in
                    nav.openFullScreen(.imageBrowser(urls: house.images, startIndex: index))
                }

                VStack(spacing: AppSpacing.lg) {
                    priceCard(house)
                    basicInfoSection(house)
                    tagSection(house)
                    descriptionSection(house)
                    HouseAIAnalysisCard(points: viewModel.aiPoints,
                                        dealSpeed: viewModel.aiDealSpeed,
                                        aiScore: house.aiRecommendScore)
                    recommendCustomerCard
                }
                .padding(AppSpacing.base)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - 价格卡

    private func priceCard(_ house: House) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text(house.title)
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.textPrimary)

                HStack(alignment: .lastTextBaseline, spacing: AppSpacing.md) {
                    Text(house.priceDescription)
                        .font(AppFont.display)
                        .foregroundStyle(AppColor.error)
                    Text(house.unitPriceDescription)
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textSecondary)
                }

                HStack(spacing: AppSpacing.sm) {
                    TagView(text: house.status.displayName, style: house.status.tagStyle, size: .small)
                    TagView(text: house.layoutDescription, style: .neutral, size: .small)
                    TagView(text: house.areaDescription, style: .neutral, size: .small)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 基础信息

    private func basicInfoSection(_ house: House) -> some View {
        SectionCard(title: "基础信息", icon: "info.circle") {
            VStack(spacing: AppSpacing.md) {
                keyValueRow("城市", house.city)
                keyValueRow("区域", house.district)
                keyValueRow("地址", house.address)
                keyValueRow("面积", house.areaDescription)
                keyValueRow("户型", house.layoutDescription)
                keyValueRow("楼层", house.floorDescription)
                keyValueRow("朝向", house.orientation.displayName)
                keyValueRow("装修", house.decoration.displayName)
                keyValueRow("房屋类型", house.propertyType.displayName)
                keyValueRow("产权", house.ownershipDescription)
                keyValueRow("建成年份", "\(house.buildYear) 年")
                keyValueRow("物业公司", house.propertyCompany ?? "未知")
                keyValueRow("开发商", house.developer ?? "未知")
            }
        }
    }

    // MARK: - 标签

    private func tagSection(_ house: House) -> some View {
        SectionCard(title: "房源标签", icon: "tag") {
            if house.tags.isEmpty {
                emptyHint("暂无标签")
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: AppSpacing.sm)],
                          alignment: .leading, spacing: AppSpacing.sm) {
                    ForEach(house.tags) { tag in
                        TagView(text: tag.displayName, style: tag.tagStyle, size: .small, icon: tag.icon)
                    }
                }
            }
        }
    }

    // MARK: - 描述

    private func descriptionSection(_ house: House) -> some View {
        SectionCard(title: "房源描述", icon: "doc.text") {
            Text(house.description ?? "暂无描述")
                .font(AppFont.bodySmall)
                .foregroundStyle(house.description == nil ? AppColor.textLight : AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - 推荐客户（占位）

    private var recommendCustomerCard: some View {
        Button {
            ToastManager.shared.info("智能客户推荐即将上线")
        } label: {
            CardView {
                HStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle().fill(AppColor.primaryLight).frame(width: 40, height: 40)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColor.primary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("推荐客户")
                            .font(AppFont.bodyMedium)
                            .foregroundStyle(AppColor.textPrimary)
                        Text("已为该房源匹配 \(viewModel.recommendedCustomerCount) 位潜在客户")
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

    // MARK: - 通用

    private func keyValueRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text(label)
                .font(AppFont.bodySmall)
                .foregroundStyle(AppColor.textSecondary)
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func emptyHint(_ text: String) -> some View {
        Text(text)
            .font(AppFont.bodySmall)
            .foregroundStyle(AppColor.textLight)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - 工具栏

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task { await viewModel.toggleFavorite() }
            } label: {
                Image(systemName: (viewModel.house?.isFavorite ?? false) ? "heart.fill" : "heart")
                    .foregroundStyle((viewModel.house?.isFavorite ?? false) ? AppColor.error : AppColor.textSecondary)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    nav.push(.houseEdit(houseId: houseId))
                } label: { Label("编辑房源", systemImage: "pencil") }
                Button(role: .destructive) {
                    requestDelete()
                } label: { Label("删除房源", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    private func requestDelete() {
        guard let house = viewModel.house else { return }
        deleteConfig = .destructive(
            title: "删除房源",
            message: "确认删除「\(house.community)」吗？\n此操作不可撤销。",
            onConfirm: {
                Task {
                    if await viewModel.delete() {
                        ToastManager.shared.success("已删除「\(house.community)」")
                        nav.pop()
                    }
                }
            }
        )
    }
}

// MARK: - Preview

#Preview("房源详情") {
    NavigationStack {
        HouseDetailView(houseId: "house-1")
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
