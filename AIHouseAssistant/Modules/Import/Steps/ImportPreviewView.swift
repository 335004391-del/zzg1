import SwiftUI

/// 步骤三：数据预览 —— 展示前 20 条，支持修改 / 删除
struct ImportPreviewView: View {

    let viewModel: ImportFlowViewModel
    /// 开始导入
    var onStartImport: () -> Void

    @State private var editingRow: ImportPreviewRow?

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(viewModel.previewRows) { row in
                        previewCard(row)
                    }
                }
                .padding(AppSpacing.base)
            }
            bottomBar
        }
        .sheet(item: $editingRow) { row in
            PreviewRowEditor(fields: viewModel.fields, row: row) { updated in
                for field in viewModel.fields {
                    viewModel.updatePreview(rowId: row.id, fieldKey: field.key,
                                            value: updated.values[field.key] ?? "")
                }
            }
        }
    }

    // MARK: - 头部统计

    private var header: some View {
        HStack {
            Text("预览前 \(viewModel.previewRows.count) 条")
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            Text("共 \(viewModel.totalRowCount) 条待导入")
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(.horizontal, AppSpacing.base)
        .padding(.vertical, AppSpacing.sm)
    }

    // MARK: - 预览卡片

    private func previewCard(_ row: ImportPreviewRow) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text(primaryText(row))
                        .font(AppFont.bodyMedium)
                        .foregroundStyle(AppColor.textPrimary)
                    Spacer()
                    Button {
                        editingRow = row
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColor.primary)
                    }
                    .buttonStyle(.plain)
                    Button {
                        viewModel.deletePreviewRow(row.id)
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(AppColor.error)
                    }
                    .buttonStyle(.plain)
                }
                Divider().foregroundStyle(AppColor.divider)
                // 字段值
                LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading),
                                    GridItem(.flexible(), alignment: .leading)],
                          spacing: AppSpacing.xs) {
                    ForEach(viewModel.fields) { field in
                        let value = row.values[field.key] ?? ""
                        if !value.isEmpty {
                            HStack(spacing: AppSpacing.xs) {
                                Text("\(field.title)：")
                                    .font(AppFont.caption2)
                                    .foregroundStyle(AppColor.textLight)
                                Text(value)
                                    .font(AppFont.caption)
                                    .foregroundStyle(AppColor.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
    }

    /// 主标题（客户取姓名，房源取标题）
    private func primaryText(_ row: ImportPreviewRow) -> String {
        switch viewModel.type {
        case .customer: return row.values["name"]?.isEmpty == false ? row.values["name"]! : "（未命名客户）"
        case .house:    return row.values["title"]?.isEmpty == false ? row.values["title"]! : "（未命名房源）"
        }
    }

    // MARK: - 底部

    private var bottomBar: some View {
        AppButton.primary("开始导入（\(viewModel.totalRowCount) 条）", icon: "square.and.arrow.down") {
            onStartImport()
        }
        .padding(AppSpacing.base)
        .background(.ultraThinMaterial)
    }
}

// MARK: - 行编辑器

private struct PreviewRowEditor: View {
    let fields: [ImportField]
    let row: ImportPreviewRow
    var onSave: (ImportPreviewRow) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var values: [String: String]

    init(fields: [ImportField], row: ImportPreviewRow, onSave: @escaping (ImportPreviewRow) -> Void) {
        self.fields = fields
        self.row = row
        self.onSave = onSave
        _values = State(initialValue: row.values)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    ForEach(fields) { field in
                        AppTextField(label: field.title, placeholder: "请输入\(field.title)",
                                     text: binding(for: field.key))
                    }
                }
                .padding(AppSpacing.base)
            }
            .background(AppColor.backgroundAlt)
            .navigationTitle("编辑数据")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        onSave(ImportPreviewRow(id: row.id, values: values))
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(get: { values[key] ?? "" }, set: { values[key] = $0 })
    }
}

// MARK: - Preview

#Preview("数据预览") {
    let vm = ImportFlowViewModel(type: .customer)
    return ImportPreviewView(viewModel: vm, onStartImport: {})
        .background(AppColor.backgroundAlt)
}
