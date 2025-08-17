import SwiftUI

struct FeedPostView: View {
    @ObservedObject var post: Post
    var body: some View {
        VStack(spacing: 15) {
            PostTopPanelView(post: post)
            
            if let parent = post.parent {
                ParentPostView(parent: parent)
            }
            
            if !post.header.isEmpty {
                Text(post.header)
                    .font(.system(size: 20, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack {
                ForEach(post.preview, id: \.self) {
                    PostBlockView(block: $0)
                }
            }
            .adultContent(post.adult_content)
            
            if post.read_more {
                Text("Читать далее")
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            PostBottomPanelView(post: post)
        }
    }
}
