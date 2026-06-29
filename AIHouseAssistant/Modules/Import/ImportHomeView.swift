import SwiftUI

/// 数据导入首页 —— 导入入口 + 模板下载 + 最近导入记录
struct ImportHomeView: View {

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel = ImportViewModel()

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    entrySection
                    templateSection
                    historySection
                }
                .padding(AppSpacing.base)
            }
        }
        .navigationTitle("数据导入")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.onAppear(repository: container.importRepository)
        }
        .onChange(of: ImportEvents.shared.version) {
            Task { await viewModel.reloadHistory() }
        }
    }

    // MARK: - 导入入口

    private var entrySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("选择导入类型")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            HStack(spacing: AppSpacing.md) {
                ImportTypeCard(type: .customer) {
                    nav.push(.importFlow(type: .customer))
                }
                ImportTypeCard(type: .house) {
                    nav.push(.importFlow(type: .house))
                }
            }
        }
    }

    // MARK: - 模板下载

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("下载模板")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            CardView {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.templates.enumerated()), id: \.element.id) { index, template in
                        TemplateRow(template: template) {
                            viewModel.downloadTemplate(template)
                        }
                        if index < viewModel.templates.count - 1 {
                            Divider().foregroundStyle(AppColor.divider)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 最近导入记录

    private var historySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("最近导入记录")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)

            if viewModel.history.isEmpty {
                CardView {
                    Text("暂无导入记录")
                        .font(AppFont.bodySmall)
                        .foregroundStyle(AppColor.textLight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, AppSpacing.sm)
                }
            } else {
                CardView {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.history.enumerated()), id: \.element.id) { index, record in
                            ImportHistoryRow(record: record)
                            if index < viewModel.history.count - 1 {
                                Divider().foregroundStyle(AppColor.divider)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("导入首页") {
    NavigationStack {
        ImportHomeView()
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
