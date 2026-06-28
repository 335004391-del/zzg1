import SwiftUI

// MARK: - 底部弹出层高度策略

enum BottomSheetHeight {
    case fixed(CGFloat)     // 固定高度
    case fraction(CGFloat)  // 屏幕高度比例（0~1）
    case auto               // 自动适应内容高度
}

// MARK: - BottomSheet ViewModifier

struct BottomSheetModifier<SheetContent: View>: ViewModifier {

    @Binding var isPresented: Bool
    let height:   BottomSheetHeight
    let title:    String?
    @ViewBuilder let sheetContent: () -> SheetContent

    @State private var dragOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    overlayBackground
                    sheetPanel
                }
            }
            .animation(AppAnimation.appear, value: isPresented)
    }

    // MARK: - 遮罩背景

    private var overlayBackground: some View {
        Color.black.opacity(0.45)
            .ignoresSafeArea()
            .onTapGesture { dismissSheet() }
            .transition(AppAnimation.fadeTransition)
    }

    // MARK: - 面板主体

    private var sheetPanel: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // 拖动把手
                dragHandle

                // 可选标题栏
                if let titleText = title {
                    titleBar(titleText)
                    Divider().foregroundStyle(AppColor.divider)
                }

                // 内容区域
                sheetContent()
                    .padding(.bottom, AppSpacing.bottomSafe)
            }
            .background(AppColor.card)
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius:  AppRadius.xl,
                topTrailingRadius: AppRadius.xl
            ))
            .appShadow(AppShadow.floating)
            .offset(y: max(0, dragOffset))
            .gesture(dragGesture)
        }
        .ignoresSafeArea(edges: .bottom)
        .transition(AppAnimation.bottomSheetTransition)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(AppColor.border)
            .frame(width: 36, height: 4)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.sm)
    }

    private func titleBar(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            Button(action: dismissSheet) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(AppColor.border)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.base)
        .padding(.bottom, AppSpacing.md)
    }

    // MARK: - 拖动手势

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height > 120 || value.velocity.height > 600 {
                    dismissSheet()
                } else {
                    withAnimation(AppAnimation.modal) { dragOffset = 0 }
                }
            }
    }

    private func dismissSheet() {
        withAnimation(AppAnimation.dismiss) {
            dragOffset = 0
            isPresented = false
        }
    }
}

// MARK: - View 扩展

extension View {
    /// 为任意 View 附加底部弹出层
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        height: BottomSheetHeight = .auto,
        title: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(BottomSheetModifier(
            isPresented: isPresented,
            height: height,
            title: title,
            sheetContent: content
        ))
    }
}

// MARK: - Preview

#Preview("底部弹出层") {
    @Previewable @State var isShowing = false

    VStack {
        Spacer()
        AppButton.primary("打开 BottomSheet") { isShowing = true }
        Spacer()
    }
    .padding(AppSpacing.base)
    .background(AppColor.backgroundAlt)
    .bottomSheet(isPresented: $isShowing, title: "筛选条件") {
        VStack(spacing: AppSpacing.md) {
            InfoCard(icon: "house.fill",      iconColor: AppColor.primary, title: "房型", value: "三房两厅")
            InfoCard(icon: "yensign.circle", iconColor: AppColor.warning, title: "预算", value: "200~300 万")
            AppButton.primary("确认筛选") { isShowing = false }
        }
        .padding(AppSpacing.base)
    }
}
