import SwiftUI
//import AppsFlyerLib

struct RootViewMC: View {
    @EnvironmentObject private var vm: LoaderViewModel
    @EnvironmentObject var viewModel: ViewModelPGM
    
    @State private var didRunConsentThisLaunch = false
    
    
    var body: some View {
        ZStack {
            switch vm.presented {
                
            case .splash:
                LoadingViewPGM()
                    .onAppear {
                        guard !didRunConsentThisLaunch else { return }
                        didRunConsentThisLaunch = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            ATTManager.shared.requestTrackingIfNeeded { _ in
                                //                            AppsFlyerLib.shared().start()
                                
                                PushManager.shared.requestPush { _ in
                                    Task { @MainActor in
                                        vm.onPushAnswered()
                                    }
                                }
                            }
                        }
                    }
            case .main:
                MainViewPGM()
                
            case .changed:
                LoaderPageView(loaderViewModel: vm, url: vm.mailLink ?? vm.link)
                    .onAppear {
                        AppDelegate.orientationLock = [.portrait, .landscapeLeft, .landscapeRight]
                    }
            }
        }
    }
}
