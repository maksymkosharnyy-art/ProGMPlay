import SwiftUI
import Combine
import WebKit

struct LoaderPageView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var loaderScreen = LoaderScreen()
    @StateObject private var networdWork = NetworkWork()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var loaderViewModel: LoaderViewModel
    let url: String
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? .black : .white)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                mainWebView
                navigationToolbar
            }
            
            if loaderScreen.isSplash {
                loadingOverlay
            }
        }
        .onReceive(loaderScreen.$leastError) { error in
            guard let errorMessage = error, isRealConnectionError(errorMessage) else { return }
            alertMessage = humanReadable(error: errorMessage)
            showAlert = !alertMessage.isEmpty
        }
        .onReceive(networdWork.$connected
            .debounce(for: .seconds(1), scheduler: RunLoop.main)) { con in
                handleConnectionChange(isConnected: con)
            }
            .alert("Connection issue", isPresented: $showAlert) {
                alertButtons
            } message: {
                Text(alertMessage)
            }
    }
}

// MARK: - Subviews
private extension LoaderPageView {
    
    var mainWebView: some View {
        LoaderPrimaryPage(urlString: url,
                          loaderScreen: loaderScreen,
                          loaderViewModel: loaderViewModel)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            AppDelegate.orientationLock = .all
            loaderScreen.leastError = nil
            showAlert = false
        }
        .onDisappear {
            AppDelegate.orientationLock = .portrait
        }
    }
    
    var navigationToolbar: some View {
        HStack {
            navButton(icon: "chevron.backward", size: 20) {
                loaderScreen.allNavigation = .back
            }
            .disabled(!loaderScreen.isBack)
            .opacity(!loaderScreen.isBack ? 0.5 : 1)
            
            Spacer()
            
            navButton(icon: "house.fill", size: 25) {
                loaderScreen.allNavigation = .home
            }
            
            Spacer()
            
            navButton(icon: "chevron.forward", size: 20) {
                loaderScreen.allNavigation = .forward
            }
            .disabled(!loaderScreen.isForward)
            .opacity(!loaderScreen.isForward ? 0.5 : 1)
        }
        .padding(.top, 10)
        .padding(.horizontal, 25)
        .padding(.bottom, 5)
        .background(Color(colorScheme == .dark ? .black : .white))
    }
    
    func navButton(icon: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    
    var loadingOverlay: some View {
        ProgressView()
            .scaleEffect(1.4)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    var alertButtons: some View {
        Group {
            Button("Try again") {
                retryLoading()
            }
            Button("OK", role: .cancel) { }
        }
    }
}

// MARK: - Helpers
private extension LoaderPageView {
    func handleConnectionChange(isConnected: Bool) {
        if !isConnected {
            alertMessage = "No Internet connection. Please check your network. And try again later."
            showAlert = true
        } else if loaderScreen.leastError != nil {
            loaderScreen.leastError = nil
            retryLoading()
        }
    }
    
    func retryLoading() {
        if let view = loaderScreen.mainView {
            if !networdWork.connected {
            } else if view.url == nil, let request = loaderScreen.homeRequest {
                view.load(request)
            } else {
                view.reload()
            }
        }
    }
    
    private func isRealConnectionError(_ e: URLError) -> Bool {
        switch e.code {
        case .notConnectedToInternet, .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
    
    private func humanReadable(error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet: return "No Internet connection."
        case .timedOut:               return "Request timed out."
        case .cannotFindHost:         return "Cannot find host."
        case .cannotConnectToHost:    return "Cannot connect to host."
        case .dnsLookupFailed:        return "DNS lookup failed."
        default:                      return error.localizedDescription
        }
    }
}
