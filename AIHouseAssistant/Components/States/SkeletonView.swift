import SwiftUI

// MARK: - Skeleton 基础组件

/// 骨架屏单元 — 带闪光动效的占位矩形
struct SkeletonView: View {

    var cornerRadius: CGFloat = AppRadius.sm
    @State private var phase: CGFloat = -1

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(shimmerGradient)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1.4
                }
            }
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: AppColor.border.opacity(0.4), location: phase - 0.4),
                .init(color: AppColor.border.opacity(0.9), location: phase),
                .init(color: AppColor.border.opacity(0.4), location: phase + 0.4),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Skeleton 客户行（业务级复用）

/// 客户列表 Skeleton 行
struct CustomerRowSkeleton: View {
    var body: some View {
        CardView {
            HStack(spacing: AppSpacing.md) {
                SkeletonView(cornerRadius: AppRadius.full)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SkeletonView().frame(width: 100, height: 14)
                    SkeletonView().frame(width: 160, height: 12)
                }
                Spacer()
                SkeletonView(cornerRadius: AppRadius.full)
                    .frame(width: 52, height: 22)
            }
        }
    }
}

/// 房源卡片 Skeleton
struct HouseCardSkeleton: View {
    var body: some View {
        CardView(padding: 0) {
            VStack(spacing: 0) {
                SkeletonView(cornerRadius: 0)
                    .frame(height: 180)
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    SkeletonView().frame(height: 16)
                    SkeletonView().frame(width: 120, height: 12)
                    SkeletonView().frame(height: 12)
                }
                .padding(AppSpacing.base)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
    }
}

// MARK: - View Modifier

struct SkeletonModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .redacted(reason: isLoading ? .placeholder : [])
            .overlay {
                if isLoading {
                    SkeletonView()
                }
            }
    }
}

extension View {
    /// 为任意 View 叠加 Skeleton 效果
    func skeleton(isLoading: Bool) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading))
    }
}

// MARK: - Preview

#Preview("骨架屏") {
    ScrollView {
        VStack(spacing: AppSpacing.md) {
            ForEach(0..<4) { _ in
                CustomerRowSkeleton()
            }
            HouseCardSkeleton()
        }
        .padding(AppSpacing.base)
    }
    .background(AppColor.backgroundAlt)
}
