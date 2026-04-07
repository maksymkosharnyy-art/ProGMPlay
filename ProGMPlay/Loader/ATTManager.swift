import Foundation
//import AppTrackingTransparency
import AdSupport

final class ATTManager {
    static let shared = ATTManager()
    private init() {}

    private let askedKey = "attAskedOnce"
    private let attResolvedKey = "attResolved"
    private let attAuthorizedKey = "attAuthorized"
    private let deviceIdKey = "deviceId"

    private let simDeviceIdKey = "simDeviceId"

    private func currentDeviceIdForServer() -> String {
        #if targetEnvironment(simulator)
        if let saved = UserDefaults.standard.string(forKey: simDeviceIdKey), !saved.isEmpty {
            return saved
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: simDeviceIdKey)
        return new
        #else
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        #endif
    }

    func requestTrackingIfNeeded(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            guard #available(iOS 14, *) else {
                let finalDevice = self.currentDeviceIdForServer()
                UserDefaults.standard.set(true, forKey: self.attResolvedKey)
                UserDefaults.standard.set(false, forKey: self.attAuthorizedKey)
                UserDefaults.standard.set(finalDevice, forKey: self.deviceIdKey)
                NotificationCenter.default.post(name: .attDidResolve, object: nil)
                completion(false)
                return
            }

//            let status = ATTrackingManager.trackingAuthorizationStatus
//            print("🟣 [ATT] current status = \(status.rawValue)")
//
//            if status != .notDetermined {
//                let granted = (status == .authorized)
//                let finalDevice = self.currentDeviceIdForServer()
//                UserDefaults.standard.set(true, forKey: self.attResolvedKey)
//                UserDefaults.standard.set(granted, forKey: self.attAuthorizedKey)
//                UserDefaults.standard.set(finalDevice, forKey: self.deviceIdKey)
//                NotificationCenter.default.post(name: .attDidResolve, object: nil)
//                print("🟣 [ATT] result status=\(status.rawValue), granted=\(granted), device=\(finalDevice)")
//                completion(granted)
//                return
//            }

            if UserDefaults.standard.bool(forKey: self.askedKey) {
                let finalDevice = self.currentDeviceIdForServer()
                UserDefaults.standard.set(true, forKey: self.attResolvedKey)
                UserDefaults.standard.set(false, forKey: self.attAuthorizedKey)
                UserDefaults.standard.set(finalDevice, forKey: self.deviceIdKey)
                NotificationCenter.default.post(name: .attDidResolve, object: nil)
                print("🟣 [ATT] askedKey=true, skip prompt, device=\(finalDevice)")
                completion(false)
                return
            }

            UserDefaults.standard.set(true, forKey: self.askedKey)
            print("🟣 [ATT] requesting authorization…")

//            ATTrackingManager.requestTrackingAuthorization { newStatus in
//                DispatchQueue.main.async {
//                    let granted = (newStatus == .authorized)
//                    let finalDevice = self.currentDeviceIdForServer()
//                    UserDefaults.standard.set(true, forKey: self.attResolvedKey)
//                    UserDefaults.standard.set(granted, forKey: self.attAuthorizedKey)
//                    UserDefaults.standard.set(finalDevice, forKey: self.deviceIdKey)
//                    NotificationCenter.default.post(name: .attDidResolve, object: nil)
//                    print("🟣 [ATT] result status=\(newStatus.rawValue), granted=\(granted), device=\(finalDevice)")
//                    completion(granted)
//                }
//            }
        }
    }
}

extension Notification.Name {
    static let attDidResolve = Notification.Name("attDidResolve")
}
