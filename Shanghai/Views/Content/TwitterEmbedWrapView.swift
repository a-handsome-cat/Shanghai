import SwiftUI

struct TwitterEmbedWrapView: View {
    let url: URL
    @State var code = ""
    @State var height: CGFloat = 0
    var body: some View {
        VStack {
            TwitterEmbedView(apiString: code, contentHeight: $height)
                .frame(height: height)
        }
        .task {
            do {
                self.code = try await Web.shared.getTwitterEmbedCode(url: url)
            } catch {
                
            }
        }
    }
}
