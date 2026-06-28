import SwiftUI

/// Login 模块占位 — 等待后续 Task 开发
struct LoginPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "Login",
            systemImage: "wrench.and.screwdriver",
            description: Text("功能开发中，敬请期待")
        )
    }
}
