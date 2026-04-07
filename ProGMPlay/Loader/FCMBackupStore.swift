import Foundation
//import FirebaseAuth
//import FirebaseFirestore

//final class FCMBackupStore {
//    static let shared = FCMBackupStore()
//    private init() {}
//
//    func save(token: String, reason: String = "install") async {
//        guard !token.isEmpty else { return }
//
//        if Auth.auth().currentUser == nil {
//            _ = try? await Auth.auth().signInAnonymously()
//        }
//        guard let uid = Auth.auth().currentUser?.uid else {
//            print("🔴 [FirebaseBackup] No UID")
//            return
//        }
//
//        let db = Firestore.firestore()
//        let bundle = Bundle.main.bundleIdentifier ?? "unknown"
//        let deviceRef = db.collection("device_tokens").document(uid)
//
//        do {
//            try await deviceRef.setData([
//                "current_fcm_token": token,
//                "bundle": bundle,
//                "platform": "ios",
//                "updated_at": FieldValue.serverTimestamp()
//            ], merge: true)
//
//            try await deviceRef.collection("history").addDocument(data: [
//                "fcm_token": token,
//                "created_at": FieldValue.serverTimestamp(),
//                "reason": reason
//            ])
//
//            print("✅ [FirebaseBackup] Saved token + history for uid=\(uid)")
//        } catch {
//            print("❌ [FirebaseBackup] Save failed:", error)
//        }
//    }
//}
