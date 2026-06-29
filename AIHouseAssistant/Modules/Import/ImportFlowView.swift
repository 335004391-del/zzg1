import SwiftUI

/// 导入流程容器 —— 串联「选择文件 → 字段映射 → 预览 → 导入 → 结果」
struct ImportFlowView: View {

    let type: ImportType

    @EnvironmentObject private var container: DependencyContainer
    @Environment(NavigationManager.self) private var nav

    @State private var viewModel: ImportFlowViewModel

    init(type: ImportType) {
        self.type = type
        // 按类型创建对应子类 ViewModel（CustomerImportViewModel / HouseImportViewModel）
        let vm: ImportFlowViewModel = (type == .customer)
            ? CustomerImportViewModel()
            : HouseImportViewModel()
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        ZStack {
            AppColor.backgroundAlt.ignoresSafeArea()
            VStack(spacing: AppSpacing.md) {
                if viewModel.step != .importing {
                    ImportStepIndicator(current: viewModel.step)
                        .padding(.top, AppSpacing.sm)
                }
                stepContent
            }
        }
        .navigationTitle("导入\(type.displayName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { stepBackButton }
        .task {
            await viewModel.onAppear(repository: container.importRepository)
        }
        .animation(AppAnimation.normal, value: viewModel.step)
    }

    // MARK: - 步骤内容

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.step {
        case .selectFile:
            FileSelectStepView(viewModel: viewModel)
        case .mapping:
            FieldMappingView(viewModel: viewModel, onNext: {})
        case .preview:
            ImportPreviewView(viewModel: viewModel) {
                Task { await viewModel.startImport() }
            }
        case .importing:
            progressView
        case .result:
            ImportResultView(viewModel: viewModel) {
                nav.pop()
            }
        }
    }

    // MARK: - 导入进度

    private var progressView: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(AppColor.surface, lineWidth: 8)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(AppColor.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)
                    .animation(AppAnimation.fast, value: viewModel.progress)
                Text("\(Int(viewModel.progress * 100))%")
                    .font(AppFont.displayMedium)
                    .foregroundStyle(AppColor.textPrimary)
            }
            VStack(spacing: AppSpacing.xs) {
                Text("正在导入数据…")
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.textSecondary)
                Text("共 \(viewModel.totalRowCount) 条")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 步骤返回按钮

    @ToolbarContentBuilder
    private var stepBackButton: some ToolbarContent {
        if viewModel.step == .mapping {
            ToolbarItem(placement: .topBarLeading) {
                Button("上一步") { viewModel.backToSelect() }
            }
        } else if viewModel.step == .preview {
            ToolbarItem(placement: .topBarLeading) {
                Button("上一步") { viewModel.backToMapping() }
            }
        }
    }
}

// MARK: - Preview

#Preview("导入流程") {
    NavigationStack {
        ImportFlowView(type: .customer)
            .environmentObject(DependencyContainer.shared)
            .environment(NavigationManager.shared)
    }
}
