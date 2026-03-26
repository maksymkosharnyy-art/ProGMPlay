import UIKit
import StoreKit

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPManagerPGM.shared)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        SKPaymentQueue.default().add(IAPManagerPGM.shared)
        return true
    }
}
