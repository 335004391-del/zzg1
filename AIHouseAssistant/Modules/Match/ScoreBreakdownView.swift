import SwiftUI

/// 评分详情 —— 各维度评分条 + 加权综合分
struct ScoreBreakdownView: View {

    let score: MatchScore

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(score.breakdown, id: \.dimension.id) { item in
                row(dimension: item.dimension, value: item.value)
            }
            Divider().foregroundStyle(AppColor.divider)
            // 综合分
            HStack {
                Text("综合评分")
                    .font(AppFont.bodySemibold)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(String(format: "%.1f", score.final))
                    .font(AppFont.title3)
                    .foregroundStyle(MatchScoreColor.color(score.final))
            }
        }
    }

    private func row(dimension: ScoreDimension, value: Double) -> some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                Text(dimension.displayName)
                    .font(AppFont.bodySmall)
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(Int(dimension.weight * 100))%")
                    .font(AppFont.caption2)
                    .foregroundStyle(AppColor.textLight)
                Spacer()
                Text("\(Int(value.rounded()))")
                    .font(AppFont.captionMedium)
                    .foregroundStyle(MatchScoreColor.color(value))
            }
            // 进度条
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AppColor.surface).frame(height: 6)
                    Capsule().fill(MatchScoreColor.color(value))
                        .frame(width: geo.size.width * value / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - 雷达图

/// 匹配雷达图 —— 由各维度分值绘制（纯几何，非占位图片）
struct MatchRadarChart: View {

    /// (维度名, 0~100 分值)
    let values: [(label: String, value: Double)]

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = size / 2 - 24
            ZStack {
                // 网格
                ForEach(1...4, id: \.self) { ring in
                    polygonPath(center: center, radius: radius * CGFloat(ring) / 4)
                        .stroke(AppColor.divider, lineWidth: 1)
                }
                // 轴线
                ForEach(values.indices, id: \.self) { i in
                    Path { p in
                        p.move(to: center)
                        p.addLine(to: point(center: center, radius: radius, index: i, ratio: 1))
                    }
                    .stroke(AppColor.divider, lineWidth: 1)
                }
                // 数据多边形
                dataPath(center: center, radius: radius)
                    .fill(AppColor.primary.opacity(0.2))
                dataPath(center: center, radius: radius)
                    .stroke(AppColor.primary, lineWidth: 2)
                // 标签
                ForEach(values.indices, id: \.self) { i in
                    Text(values[i].label)
                        .font(AppFont.caption2)
                        .foregroundStyle(AppColor.textSecondary)
                        .position(point(center: center, radius: radius + 14, index: i, ratio: 1))
                }
            }
        }
        .frame(height: 240)
    }

    // MARK: - 几何

    private func angle(for index: Int) -> Double {
        let step = 2 * Double.pi / Double(values.count)
        return -Double.pi / 2 + step * Double(index)
    }

    private func point(center: CGPoint, radius: CGFloat, index: Int, ratio: CGFloat) -> CGPoint {
        let a = angle(for: index)
        let r = Double(radius) * Double(ratio)
        return CGPoint(x: center.x + CGFloat(cos(a) * r),
                       y: center.y + CGFloat(sin(a) * r))
    }

    private func polygonPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { p in
            for i in values.indices {
                let pt = point(center: center, radius: radius, index: i, ratio: 1)
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }

    private func dataPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { p in
            for i in values.indices {
                let ratio = CGFloat(values[i].value / 100)
                let pt = point(center: center, radius: radius, index: i, ratio: max(0.02, ratio))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview("评分详情") {
    let score = ScoringEngine().score(customer: MockData.customer1, house: MockData.house1)
    return ScrollView {
        VStack(spacing: AppSpacing.xl) {
            ScoreBreakdownView(score: score)
            MatchRadarChart(values: score.breakdown.map { ($0.dimension.displayName, $0.value) })
        }
        .padding(AppSpacing.base)
    }
    .background(AppColor.background)
}
