import StoreKit
import SwiftUI
//import AppTrackingTransparency
//import AdSupport
//import AppsFlyerLib
//import FirebaseCore
//import FirebaseMessaging
import UserNotifications

final class AppDelegate: NSObject,
                         UIApplicationDelegate{

    private let appsFlyerDevKey = "AppsFlyer Dev Key" // ИЗМЕНИТЬ
    private let appleAppID      = "Apple AppID" // ИЗМЕНИТЬ

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(IAPManagerPGM.shared)
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        log("🚀 didFinishLaunching")

        SKPaymentQueue.default().add(IAPManagerPGM.shared)
        UserDefaults.standard.set(false, forKey: "apnsReady")
        UserDefaults.standard.removeObject(forKey: "apnsTokenHex")

//        FirebaseApp.configure()
//        Messaging.messaging().delegate = self
//        Messaging.messaging().isAutoInitEnabled = true
        log("✅ Firebase configured")

//        let af = AppsFlyerLib.shared()
//        af.appsFlyerDevKey = appsFlyerDevKey
//        af.appleAppID      = appleAppID
//        af.delegate        = self
//        af.isDebug         = false

        UNUserNotificationCenter.current().delegate = self

        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }

    func onConversionDataSuccess(_ data: [AnyHashable : Any]) {
        print("🎯 AppsFlyer Conversion Data: \(data)")
    }

    func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyer error: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let apns = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        log("📬 APNs token: \(apns)")

        UserDefaults.standard.set(true, forKey: "apnsReady")
        UserDefaults.standard.set(apns, forKey: "apnsTokenHex")
        NotificationCenter.default.post(name: .apnsTokenDidUpdate, object: nil, userInfo: ["apns": apns])

//        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log("❌ APNs register failed: \(error)")
        UserDefaults.standard.set(false, forKey: "apnsReady")
    }

    fileprivate func log(_ message: String) {
        print("[AppDelegate] \(message)")
    }

    static var orientationLock = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orient")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orient")
                }
            }
        }
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}

//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        guard let token = fcmToken, !token.isEmpty else {
//            log("⚠️ didReceiveRegistrationToken empty")
//            return
//        }
//        UserDefaults.standard.set(token, forKey: "fcmToken")
//        log("🔥 FCM token (delegate): \(token)")
//        NotificationCenter.default.post(name: .fcmTokenDidUpdate, object: nil, userInfo: ["token": token])
//    }
//}

extension Notification.Name {
    static let fcmTokenDidUpdate = Notification.Name("fcmTokenDidUpdate")
    static let pushPermissionGranted = Notification.Name("pushPermissionGranted")
    static let pushPermissionDenied = Notification.Name("pushPermissionDenied")
    static let apnsTokenDidUpdate = Notification.Name("apnsTokenDidUpdate")
}
