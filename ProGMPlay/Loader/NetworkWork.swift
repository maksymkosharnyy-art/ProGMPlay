import Combine
import Network

final class NetworkWork: ObservableObject {
    @Published private(set) var connected = true
    
    private let pathMonitor = NWPathMonitor()
    private let disQueue = DispatchQueue(label: "Reachability")
    
    init() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connected = (path.status == .satisfied)
            }
        }
        pathMonitor.start(queue: disQueue)
    }
    
    deinit {
        pathMonitor.cancel()
    }
}

