import SwiftUI

@main
struct ProGMPlayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = ViewModelPGM()
    @StateObject private var iap = IAPManagerPGM.shared
    
    var body: some Scene {
        WindowGroup {
            MainViewPGM()
                .environmentObject(viewModel)
                .environmentObject(iap)
        }
    }
}
