import SwiftUI

/// 搜索栏 — 带胶囊形背景、清空、取消按钮
struct SearchBar: View {

    let placeholder: String
    @Binding var text: String
    var onCancel: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @State private var showCancel = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            searchField
            if showCancel {
                cancelButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(AppAnimation.fast, value: showCancel)
        .onChange(of: isFocused) { _, focused in
            showCancel = focused || !text.isEmpty
        }
    }

    // MARK: - 子视图

    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColor.textLight)

            TextField(placeholder, text: $text)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
                .submitLabel(.search)
                .focused($isFocused)

            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColor.placeholder)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: 40)
        .background(AppColor.backgroundAlt)
        .clipShape(Capsule())
    }

    private var cancelButton: some View {
        Button {
            text = ""
            isFocused = false
            showCancel = false
            onCancel?()
        } label: {
            Text("取消")
                .font(AppFont.bodyMedium)
                .foregroundStyle(AppColor.primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("搜索栏") {
    VStack(spacing: AppSpacing.lg) {
        SearchBar(placeholder: "搜索客户、房源…", text: .constant(""))
        SearchBar(placeholder: "搜索", text: .constant("张三"))
    }
    .padding(AppSpacing.base)
    .background(AppColor.background)
}
