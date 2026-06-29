import SwiftUI

/// 步骤五：导入结果 —— 成功/失败统计 + 错误明细 + 导出错误报告
struct ImportResultView: View {

    let viewModel: ImportFlowViewModel
    /// 完成（退出流程）
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    summaryCard
                    if let result = viewModel.result, !result.errors.isEmpty {
                        errorCard(result.errors)
                    }
                }
                .padding(AppSpacing.base)
            }
            bottomBar
        }
    }

    // MARK: - 汇总

    private var summaryCard: some View {
        CardView {
            VStack(spacing: AppSpacing.lg) {
                ZStack {
                    Circle()
                        .fill(AppColor.success.opacity(0.12))
                        .frame(width: 72, height: 72)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColor.success)
                }
                Text("导入完成")
                    .font(AppFont.title3)
                    .foregroundStyle(AppColor.textPrimary)

                if let result = viewModel.result {
                    HStack(spacing: AppSpacing.base) {
                        statBox(title: "总数", value: "\(result.total)", color: AppColor.textSecondary)
                        statBox(title: "成功", value: "\(result.success)", color: AppColor.success)
                        statBox(title: "失败", value: "\(result.failed)", color: AppColor.error)
                    }
                    Text(String(format: "成功率 %.0f%% · 耗时 %.1fs",
                                result.successRate * 100, result.duration))
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textLight)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func statBox(title: String, value: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(value)
                .font(AppFont.displayMedium)
                .foregroundStyle(color)
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    // MARK: - 错误明细

    private func errorCard(_ errors: [ImportRowError]) -> some View {
        SectionCard(title: "失败明细", subtitle: "共 \(errors.count) 条",
                    icon: "exclamationmark.triangle",
                    actionTitle: "导出报告",
                    onAction: { viewModel.exportErrorReport() }) {
            VStack(spacing: 0) {
                ForEach(errors.prefix(50)) { error in
                    HStack(spacing: AppSpacing.md) {
                        Text("第 \(error.row) 行")
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                            .frame(width: 64, alignment: .leading)
                        TagView(text: error.reason, style: .error, size: .small)
                        Spacer()
                    }
                    .padding(.vertical, AppSpacing.sm)
                    if error.id != errors.prefix(50).last?.id {
                        Divider().foregroundStyle(AppColor.divider)
                    }
                }
            }
        }
    }

    // MARK: - 底部

    private var bottomBar: some View {
        HStack(spacing: AppSpacing.md) {
            AppButton(title: "再次导入", icon: "arrow.clockwise",
                      variant: .outline, isFullWidth: true) {
                viewModel.reset()
            }
            AppButton(title: "完成", icon: "checkmark",
                      variant: .primary, isFullWidth: true) {
                onFinish()
            }
        }
        .padding(AppSpacing.base)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Preview

#Preview("导入结果") {
    let vm = ImportFlowViewModel(type: .customer)
    return ImportResultView(viewModel: vm, onFinish: {})
        .background(AppColor.backgroundAlt)
}
