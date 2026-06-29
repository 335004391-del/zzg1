import SwiftUI

/// 房源图片轮播 —— 支持左右滑动、页码指示、点击放大（全屏占位）
/// 图片为远程 URL（Mock 阶段无真实图），使用稳定渐变占位
struct HouseImageCarousel: View {

    /// 图片标识列表（数量决定页数）
    let images: [String]
    /// 封面配色种子
    let coverSeed: Int
    /// 点击某张图片（进入全屏浏览占位）
    var onTapImage: (Int) -> Void

    @State private var currentIndex = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            if images.isEmpty {
                placeholderTile(index: 0)
                    .frame(height: 260)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, _ in
                        placeholderTile(index: index)
                            .onTapGesture { onTapImage(index) }
                            .tag(index)
                    }
                }
                .frame(height: 260)
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.bottom, AppSpacing.md)
            }
        }
        .overlay(alignment: .topTrailing) {
            if !images.isEmpty {
                Text("\(currentIndex + 1) / \(images.count)")
                    .font(AppFont.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.3))
                    .clipShape(Capsule())
                    .padding(AppSpacing.md)
            }
        }
    }

    // MARK: - 占位图块

    private func placeholderTile(index: Int) -> some View {
        ZStack {
            HouseCoverPalette.gradient(seed: coverSeed + index)
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.white.opacity(0.85))
                Text("点击查看大图")
                    .font(AppFont.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - 页码指示

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(images.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.white : Color.white.opacity(0.45))
                    .frame(width: index == currentIndex ? 8 : 6,
                           height: index == currentIndex ? 8 : 6)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .background(.black.opacity(0.25))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("图片轮播") {
    HouseImageCarousel(images: ["a", "b", "c", "d"], coverSeed: 2, onTapImage: { _ in })
}
