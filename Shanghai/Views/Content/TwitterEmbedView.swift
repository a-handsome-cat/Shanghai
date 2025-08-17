import SwiftUI
import WebKit

struct TwitterEmbedView: UIViewRepresentable {
    let apiString: String
    var webView: WKWebView = WKWebView()
    @Binding var contentHeight: CGFloat
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: TwitterEmbedView

        init(_ parent: TwitterEmbedView) {
            self.parent = parent
        }

        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "heightHandler", let height = message.body as? CGFloat {
                DispatchQueue.main.async {
                    self.parent.contentHeight = height
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.configuration.userContentController.add(context.coordinator, name: "heightHandler")
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString: String = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Twitter Embed Full Width</title>
        <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
        <script>
            function updateHeight() {
                setTimeout(() => {
                    const height = document.documentElement.scrollHeight;
                    window.webkit.messageHandlers.heightHandler.postMessage(height);
                }, 500);
            }

            window.onload = updateHeight;
            window.onresize = updateHeight;

            const observer = new MutationObserver(updateHeight);
            observer.observe(document.body, { childList: true, subtree: true });
        </script>
        <style>
            .twitter-container {
                display: flex;
                justify-content: center;
                width: 100%;
            }
            blockquote.twitter-tweet {
                width: 100% !important;
                max-width: none !important;
            }
        </style>
    </head>
    <body>
        <div class="twitter-container">
            \(apiString)
        </div>
    </body>
    </html>
    """
        
        uiView.loadHTMLString(htmlString, baseURL: nil)
        uiView.scrollView.isScrollEnabled = false
    }
}
