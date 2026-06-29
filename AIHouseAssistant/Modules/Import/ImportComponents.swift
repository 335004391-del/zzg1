import SwiftUI

// MARK: - 导入类型大卡片（首页）

/// 首页「导入客户 / 导入房源」入口卡片
struct ImportTypeCard: View {
    let type: ImportType
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            CardView {
                VStack(spacing: AppSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(AppColor.primaryLight)
                            .frame(width: 56, height: 56)
                        Image(systemName: type == .customer ? "person.2.fill" : "building.2.fill")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(AppColor.primary)
                    }
                    Text("导入\(type.displayName)")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("支持 xlsx / xls / csv")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 导入历史行

struct ImportHistoryRow: View {
    let record: ImportRecord

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppRadius.sm)
                    .fill((record.isAllSuccess ? AppColor.success : AppColor.warning).opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: record.type == .customer ? "person.2.fill" : "building.2.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(record.isAllSuccess ? AppColor.success : AppColor.warning)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(record.fileName)
                    .font(AppFont.bodyMedium)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)
                Text("\(record.operatorName) · \(relativeTime)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textLight)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    TagView(text: "成功 \(record.successCount)", style: .success, size: .small)
                    if record.failedCount > 0 {
                        TagView(text: "失败 \(record.failedCount)", style: .error, size: .small)
                    }
                }
                Text(String(format: "耗时 %.1fs", record.duration))
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColor.textLight)
            }
        }
        .padding(.vertical, AppSpacing.sm)
    }

    private var relativeTime: String {
        let days = Calendar.current.dateComponents([.day], from: record.importedAt, to: Date()).day ?? 0
        switch days {
        case ..<1: return "今天"
        case 1:    return "昨天"
        default:   return "\(days) 天前"
        }
    }
}

// MARK: - 模板下载行

struct TemplateRow: View {
    let template: ImportTemplate
    var onDownload: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: template.format.icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColor.primary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textPrimary)
                Text(template.format.displayName)
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColor.textLight)
            }
            Spacer()
            Button(action: onDownload) {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColor.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

// MARK: - 文件卡片（文件选择步骤）

struct ImportFileCard: View {
    let file: ImportFile
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: file.format.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(AppColor.primary)
                    .frame(width: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.name)
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)
                    Text("\(file.rowCount) 条 · \(file.headers.count) 列")
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: isSelected ? 20 : 13, weight: .medium))
                    .foregroundStyle(isSelected ? AppColor.success : AppColor.textLight)
            }
            .padding(AppSpacing.base)
            .background(AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(isSelected ? AppColor.primary : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 步骤指示器

struct ImportStepIndicator: View {
    let current: ImportStep

    private let steps = ImportStep.indicatorSteps

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                stepDot(index: index, step: step)
                if index < steps.count - 1 {
                    Rectangle()
                        .fill(isDone(step) ? AppColor.primary : AppColor.divider)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, AppSpacing.base)
    }

    private func stepDot(index: Int, step: ImportStep) -> some View {
        VStack(spacing: AppSpacing.xs) {
            ZStack {
                Circle()
                    .fill(isActiveOrDone(step) ? AppColor.primary : AppColor.surface)
                    .frame(width: 28, height: 28)
                if isDone(step) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(index + 1)")
                        .font(AppFont.caption2)
                        .foregroundStyle(isActiveOrDone(step) ? .white : AppColor.textLight)
                }
            }
            Text(step.title)
                .font(AppFont.caption2)
                .foregroundStyle(isActiveOrDone(step) ? AppColor.primary : AppColor.textLight)
        }
        .fixedSize()
    }

    /// 当前步骤排名（importing 归入 preview 之后、result 之前）
    private var currentRank: Int {
        switch current {
        case .selectFile: return 0
        case .mapping:    return 1
        case .preview:    return 2
        case .importing:  return 2
        case .result:     return 3
        }
    }

    private func rank(of step: ImportStep) -> Int {
        steps.firstIndex(of: step) ?? 0
    }

    private func isDone(_ step: ImportStep) -> Bool { rank(of: step) < currentRank }
    private func isActiveOrDone(_ step: ImportStep) -> Bool { rank(of: step) <= currentRank }
}

// MARK: - Preview

#Preview("导入组件") {
    ScrollView {
        VStack(spacing: AppSpacing.lg) {
            ImportStepIndicator(current: .preview)
            HStack(spacing: AppSpacing.md) {
                ImportTypeCard(type: .customer, onTap: {})
                ImportTypeCard(type: .house, onTap: {})
            }
        }
        .padding(AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
