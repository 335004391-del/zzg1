import SwiftUI

/// AI 模块占位 — 等待后续 Task 开发
struct AIPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "AI",
            systemImage: "wrench.and.screwdriver",
            description: Text("功能开发中，敬请期待")
        )
    }
}
