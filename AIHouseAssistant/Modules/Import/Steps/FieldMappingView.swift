import SwiftUI

/// 步骤二：字段映射 —— Excel 表头 → 系统字段（自动匹配 + 人工修改）
struct FieldMappingView: View {

    let viewModel: ImportFlowViewModel
    /// 进入预览
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    hintBanner
                    CardView(padding: 0) {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.fields.enumerated()), id: \.element.id) { index, field in
                                mappingRow(field)
                                if index < viewModel.fields.count - 1 {
                                    Divider().foregroundStyle(AppColor.divider)
                                }
                            }
                        }
                    }
                }
                .padding(AppSpacing.base)
            }
            bottomBar
        }
    }

    // MARK: - 提示

    private var hintBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "wand.and.stars")
                .foregroundStyle(AppColor.aiPurple)
            Text("已为你自动匹配字段，请确认或手动调整")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColor.aiPurple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    // MARK: - 单字段映射行

    private func mappingRow(_ field: ImportField) -> some View {
        HStack(spacing: AppSpacing.md) {
            // 系统字段
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    Text(field.title)
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.textPrimary)
                    if field.required {
                        Text("必填")
                            .font(AppFont.caption2)
                            .foregroundStyle(AppColor.error)
                    }
                }
                Text("系统字段：\(field.key)")
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColor.textLight)
            }

            Spacer()

            Image(systemName: "arrow.left")
                .font(.system(size: 12))
                .foregroundStyle(AppColor.textLight)

            // Excel 表头选择
            Menu {
                Button("不导入") { viewModel.setMapping(field: field.key, header: nil) }
                Divider()
                ForEach(viewModel.headerOptions, id: \.self) { header in
                    Button(header) { viewModel.setMapping(field: field.key, header: header) }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text(viewModel.mapping[field.key] ?? "不导入")
                        .font(AppFont.bodySmall)
                        .foregroundStyle(viewModel.mapping[field.key] == nil ? AppColor.textLight : AppColor.primary)
                        .lineLimit(1)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColor.textLight)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColor.surface)
                .clipShape(Capsule())
            }
        }
        .padding(AppSpacing.base)
    }

    // MARK: - 底部操作

    private var bottomBar: some View {
        VStack(spacing: AppSpacing.sm) {
            if !viewModel.canProceedToPreview {
                Text("请先映射必填字段：\(viewModel.unmappedRequiredFields.map(\.title).joined(separator: "、"))")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.error)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            AppButton.primary("下一步：预览数据", icon: "arrow.right",
                              isDisabled: !viewModel.canProceedToPreview) {
                viewModel.confirmMapping()
                onNext()
            }
        }
        .padding(AppSpacing.base)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Preview

#Preview("字段映射") {
    let vm = ImportFlowViewModel(type: .customer)
    return FieldMappingView(viewModel: vm, onNext: {})
        .background(AppColor.backgroundAlt)
}
