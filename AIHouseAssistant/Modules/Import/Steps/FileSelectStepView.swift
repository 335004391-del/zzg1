import SwiftUI

/// 步骤一：选择文件（客户/房源导入入口内容）
struct FileSelectStepView: View {

    let viewModel: ImportFlowViewModel

    /// 支持的格式（含预留）
    private let formats: [ImportFileFormat] = [.xlsx, .xls, .csv, .numbers, .googleSheet]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                formatSection
                fileSection
            }
            .padding(AppSpacing.base)
        }
    }

    // MARK: - 支持格式

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("支持的文件格式")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: AppSpacing.sm)],
                      alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(formats, id: \.self) { format in
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: format.icon)
                            .font(.system(size: 12))
                        Text(format.displayName)
                            .font(AppFont.caption2)
                        if !format.isSupported {
                            Text("即将支持")
                                .font(AppFont.caption2)
                                .foregroundStyle(AppColor.warning)
                        }
                    }
                    .foregroundStyle(format.isSupported ? AppColor.textPrimary : AppColor.textLight)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColor.card)
                    .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - 文件列表

    private var fileSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("选择要导入的文件")
                .font(AppFont.labelMedium)
                .foregroundStyle(AppColor.textSecondary)

            if viewModel.isLoadingFiles {
                AppLoadingView(message: "正在读取文件…")
                    .frame(height: 160)
            } else {
                ForEach(viewModel.availableFiles) { file in
                    ImportFileCard(file: file, isSelected: viewModel.selectedFile?.id == file.id) {
                        viewModel.selectFile(file)
                    }
                }
                Text("提示：从手机文件、邮件附件或云盘选择 Excel / CSV 文件")
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColor.textLight)
            }
        }
    }
}

// MARK: - Preview

#Preview("选择文件") {
    FileSelectStepView(viewModel: {
        let vm = ImportFlowViewModel(type: .customer)
        return vm
    }())
    .background(AppColor.backgroundAlt)
}
