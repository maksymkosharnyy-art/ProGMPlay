import SwiftUI
@preconcurrency import WebKit
import Combine

enum AllNavigation {
    case none, home, back, forward
}

class LoaderScreen: ObservableObject {
    @Published var allNavigation: AllNavigation = .none
    
    @Published var isSplash = false
    @Published var isBack = false
    @Published var isForward = false
    @Published var leastError: URLError?
    
    weak var mainView: WKWebView?
    var homeRequest: URLRequest?
}

