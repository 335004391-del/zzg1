import SwiftUI

/// Settings 模块占位 — 等待后续 Task 开发
struct SettingsPlaceholderView: View {
    var body: some View {
        ContentUnavailableView(
            "Settings",
            systemImage: "wrench.and.screwdriver",
            description: Text("功能开发中，敬请期待")
        )
    }
}
