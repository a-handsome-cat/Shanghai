import SwiftUI
import WebKit

struct LoginWebView: UIViewRepresentable {
    let url: URL
    let afterTokenFound: (String, String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
        uiView.scrollView.isScrollEnabled = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(afterTokenFound: afterTokenFound)
    }
}

class Coordinator: NSObject, WKNavigationDelegate {
    let afterTokenFound: (String, String) -> Void
    
    init(afterTokenFound: @escaping (String, String) -> Void) {
        self.afterTokenFound = afterTokenFound
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        var xcsrf = ""
        var bearer = ""
        
        cookieStore.getAllCookies { cookies in
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
                if cookie.name == "X-USER" {
                    bearer = "Bearer \(cookie.value.replacing("%7C", with: "|"))"
                } else if cookie.name == "XSRF-TOKEN" {
                    xcsrf = cookie.value
                }
            }
            if !xcsrf.isEmpty && !bearer.isEmpty {
                self.afterTokenFound(xcsrf, bearer)
            }
        }
    }
}
