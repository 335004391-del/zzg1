import SwiftUI

/// 根视图 — 负责全局导航栈入口
struct RootView: View {

    @EnvironmentObject private var container: DependencyContainer

    var body: some View {
        NavigationStack {
            PlaceholderHomeView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(DependencyContainer.shared)
}
