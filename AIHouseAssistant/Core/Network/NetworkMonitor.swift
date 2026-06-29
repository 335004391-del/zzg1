import Foundation
import Network

/// 网络连接监听器 — 实时监控 WiFi / 4G / 5G / 离线状态变化
@MainActor
@Observable
final class NetworkMonitor {

    // MARK: - 单例

    static let shared = NetworkMonitor()

    // MARK: - 可观测状态

    /// 当前是否有网络连接
    private(set) var isConnected: Bool = true

    /// 当前网络类型
    private(set) var connectionType: ConnectionType = .unknown

    // MARK: - 内部

    private let monitor = NWPathMonitor()
    private let queue   = DispatchQueue(label: "com.aihouseassistant.network", qos: .utility)

    private init() {
        startMonitoring()
    }

    // MARK: - 监听

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                self?.update(path: path)
            }
        }
        monitor.start(queue: queue)
        AppLogger.info("网络监听已启动", category: .network)
    }

    private func update(path: NWPath) {
        isConnected    = path.status == .satisfied
        connectionType = resolveType(from: path)
        AppLogger.debug(
            "网络状态: \(connectionType.label) — \(isConnected ? "在线" : "离线")",
            category: .network
        )
    }

    private func resolveType(from path: NWPath) -> ConnectionType {
        guard path.status == .satisfied else { return .none }
        if path.usesInterfaceType(.wifi)          { return .wifi }
        if path.usesInterfaceType(.cellular)      { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        return .other
    }

    deinit { monitor.cancel() }
}

// MARK: - 网络类型枚举

extension NetworkMonitor {

    enum ConnectionType {
        case wifi
        case cellular   // 4G / 5G
        case ethernet
        case other
        case none
        case unknown

        var label: String {
            switch self {
            case .wifi:     return "WiFi"
            case .cellular: return "蜂窝网络"
            case .ethernet: return "有线网络"
            case .other:    return "其他"
            case .none:     return "无网络"
            case .unknown:  return "未知"
            }
        }
    }
}
