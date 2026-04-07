import Foundation

struct MainResponse: Decodable {
    let url: String
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .serverError(let code): return "Server error: \(code)"
        case .decodingError: return "Failed to decode response"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    private let installURL = "https://coolsterclickwillow.click/v1/public/install" // ИЗМЕНИТЬ ДОМЕН
    private let refreshURL = "https://coolsterclickwillow.click/v1/public/refresh" // ИЗМЕНИТЬ ДОМЕН

    private func logBody(_ tag: String, body: [String: String]) {
        let required = ["bundle", "fcm_token", "device", "appsFlyerId"]
        let present = required.filter { (body[$0]?.isEmpty == false) }
        print("🌐 [\(tag)] Body fields OK ✅ (\(present.count)/4)")
        if let data = try? JSONEncoder().encode(body),
           let s = String(data: data, encoding: .utf8) {
            print("🌐 [\(tag)] Body:", s)
        } else {
            print("🌐 [\(tag)] Body: <encode failed>")
        }
    }

    func fetchInstallURL(bundle: String, fcmToken: String, device: String, appsFlyerId: String) async throws -> MainResponse {
        guard let url = URL(string: installURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "bundle": bundle,
//            "fcm_token": fcmToken,
//            "device": device,
//            "appsFlyerId": appsFlyerId
        ]

        print("🌐 [InstallAPI] URL:", url.absoluteString)
        print("🌐 [InstallAPI] Method:", request.httpMethod ?? "nil")
        logBody("InstallAPI", body: body)

        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

            print("🌐 [InstallAPI] Status:", http.statusCode)
            if let text = String(data: data, encoding: .utf8) {
                print("🌐 [InstallAPI] Response body:", text)
            }

            guard http.statusCode == 200 else { throw APIError.serverError(http.statusCode) }

            do {
                let decoded = try JSONDecoder().decode(MainResponse.self, from: data)
                print("✅ [InstallAPI] Decoded url:", decoded.url)
                return decoded
            } catch {
                throw APIError.decodingError
            }
        } catch {
            print("❌ [InstallAPI] Network error:", error.localizedDescription)
            throw APIError.unknown(error)
        }
    }

    func refreshFCMToken(bundle: String, fcmToken: String, device: String, appsFlyerId: String) async throws {
        guard let url = URL(string: refreshURL) else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "bundle": bundle,
            "fcm_token": fcmToken,
            "device": device,
            "appsFlyerId": appsFlyerId
        ]

        print("🌐 [RefreshAPI] URL:", url.absoluteString)
        print("🌐 [RefreshAPI] Method:", request.httpMethod ?? "nil")
        logBody("RefreshAPI", body: body)

        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

            print("🌐 [RefreshAPI] Status:", http.statusCode)
            if let text = String(data: data, encoding: .utf8) {
                print("🌐 [RefreshAPI] Response body:", text)
            }

            guard (200...299).contains(http.statusCode) else { throw APIError.serverError(http.statusCode) }
        } catch {
            print("❌ [RefreshAPI] Network error:", error.localizedDescription)
            throw APIError.unknown(error)
        }
    }
}
