import UIKit
import UserNotifications

final class PushManager {
    static let shared = PushManager()
    private init() {}

    func requestPush(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {

            case .notDetermined:
                DispatchQueue.main.async {
                    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(true, forKey: "pushPermissionHandled")

                            if granted {
                                UIApplication.shared.registerForRemoteNotifications()
                                NotificationCenter.default.post(name: .pushPermissionGranted, object: nil)
                            } else {
                                NotificationCenter.default.post(name: .pushPermissionDenied, object: nil)
                            }

                            completion(granted)
                        }
                    }
                }

            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "pushPermissionHandled")
                    UIApplication.shared.registerForRemoteNotifications()
                    NotificationCenter.default.post(name: .pushPermissionGranted, object: nil)
                    completion(true)
                }

            case .denied:
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "pushPermissionHandled")
                    NotificationCenter.default.post(name: .pushPermissionDenied, object: nil)
                    completion(false)
                }

            @unknown default:
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "pushPermissionHandled")
                    NotificationCenter.default.post(name: .pushPermissionDenied, object: nil)
                    completion(false)
                }
            }
        }
    }
}
