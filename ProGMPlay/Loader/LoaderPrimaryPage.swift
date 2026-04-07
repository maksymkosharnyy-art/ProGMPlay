import SwiftUI
import Combine
@preconcurrency import WebKit

struct LoaderPrimaryPage: UIViewRepresentable {
    let urlString: String
    @ObservedObject var loaderScreen: LoaderScreen
    var loaderViewModel: LoaderViewModel
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = preferences
        
        let script = """
        Object.defineProperty(navigator, 'userAgent', {
            get: function () {
                return 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
            }
        });
        
        window.chrome = {
            runtime: {}
        };
        
        window.open = function(url, name, specs) {
            window.location.href = url;
            return window;
        };
        
        document.createElement = (function() {
            var original = document.createElement;
            return function(tag) {
                var element = original.call(document, tag);
                if (tag === 'iframe') {
                    element.setAttribute('sandbox', 'allow-same-origin allow-scripts allow-forms allow-popups allow-modals');
                }
                return element;
            };
        })();
        """
        
        let userScript = WKUserScript(source: script,
                                      injectionTime: .atDocumentStart,
                                      forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)
        
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences.javaScriptEnabled = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        let myLoader = WKWebView(frame: .zero, configuration: configuration)
        myLoader.navigationDelegate = context.coordinator
        myLoader.uiDelegate = context.coordinator
        myLoader.allowsBackForwardNavigationGestures = true
        myLoader.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        loaderScreen.mainView = myLoader
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            context.coordinator.homeRequest = request
            loaderScreen.homeRequest = request
            myLoader.load(request)
        } else {
            print("❌ Некорректный URL: \(urlString)")
        }
        
        loaderScreen.$allNavigation
            .receive(on: RunLoop.main)
            .sink { [weak myLoader] action in
                guard let myLoader else { return }
                switch action {
                case .back:
                    if myLoader.canGoBack { myLoader.goBack() }
                case .forward:
                    if myLoader.canGoForward { myLoader.goForward() }
                case .home:
                    if let request = context.coordinator.homeRequest { myLoader.load(request) }
                case .none:
                    break
                }
                self.loaderScreen.allNavigation = .none
            }
            .store(in: &context.coordinator.cancellables)
        
        return myLoader
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: LoaderPrimaryPage
        var cancellables = Set<AnyCancellable>()
        var homeRequest: URLRequest?
        
        private var suppressSpinnerForThisNav = false
        
        init(_ parent: LoaderPrimaryPage) {
            self.parent = parent
            super.init()
        }
        
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            suppressSpinnerForThisNav = (navigationAction.navigationType == .backForward)
            
            if let url = navigationAction.request.url?.absoluteString {
                if url.contains("accounts.google.com") ||
                   url.contains("oauth2") ||
                   url.contains("google.com/signin") {
                    decisionHandler(.allow)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                if url.absoluteString.contains("accounts.google.com") ||
                   url.absoluteString.contains("oauth2") {
                    webView.load(URLRequest(url: url))
                } else {
                    UIApplication.shared.open(url)
                }
            }
            return nil
        }
        
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            completionHandler()
        }
        
        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void) {
            completionHandler(true)
        }
        
        func webView(_ webView: WKWebView,
                     runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void) {
            completionHandler(defaultText)
        }
        
        private func publishNavState(_ webView: WKWebView) {
            DispatchQueue.main.async {
                self.parent.loaderScreen.isBack = webView.canGoBack
                self.parent.loaderScreen.isForward = webView.canGoForward
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            if !suppressSpinnerForThisNav {
                DispatchQueue.main.async {
                    self.parent.loaderScreen.isSplash = true
                    self.parent.loaderScreen.leastError = nil
                }
            }
            publishNavState(webView)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            publishNavState(webView)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.loaderScreen.isSplash = false
                self.parent.loaderScreen.leastError = nil
            }
            suppressSpinnerForThisNav = false
            publishNavState(webView)
        }
        
        private func handle(error: Error, webView: WKWebView) {
            let nsError = error as NSError
            
            if let urlError = error as? URLError, urlError.code == .cancelled {
                publishNavState(webView); return
            }
            
            if nsError.domain == "WebKitErrorDomain" && nsError.code == 102 {
                publishNavState(webView); return
            }
            
            if let failingURL = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL,
               failingURL.host?.contains("onesignal.com") == true {
                return
            }
            
            DispatchQueue.main.async {
                self.parent.loaderScreen.isSplash = false
                if let urlError = error as? URLError {
                    self.parent.loaderScreen.leastError = urlError
                }
            }
            suppressSpinnerForThisNav = false
            publishNavState(webView)
        }
        
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            handle(error: error, webView: webView)
        }
        
        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            handle(error: error, webView: webView)
        }
        
        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            if webView.url != nil { webView.reload() }
        }
        
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            decisionHandler(.grant)
        }
    }
}
