import SwiftUI

@main
struct ProGMPlayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = ViewModelPGM()
    @StateObject private var iap = IAPManagerPGM.shared
    
    var body: some Scene {
        WindowGroup {
            RootViewMC()
                .environmentObject(LoaderViewModel())
                .environmentObject(viewModel)
                .environmentObject(iap)
        }
    }
}
