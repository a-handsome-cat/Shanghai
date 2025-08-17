import SwiftUI

struct PostView: View {
    @State var commentEditorText = ""
    @State var commentEditorHeight: CGFloat = 0
    
    @StateObject var provider: PostViewModel
    
    @State var postDownloaded = false
    @State var commentsDownloaded = false
    
    init(post: Post) {
        self._provider = StateObject(wrappedValue: PostViewModel(post: post, postId: post.id))
    }
    
    init(id: Int, highlightedComment: Int? = nil) {
        self._provider = StateObject(wrappedValue: PostViewModel(postId: id, highlightedComment: highlightedComment))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                List {
                    if let post = provider.post {
                        Group {
                            PostTopPanelView(post: post)
                            if !post.header.isEmpty {
                                Text(post.header)
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .listRowSeparator(.hidden)
                            }
                            ForEach(post.blocks, id: \.self) {
                                PostBlockView(block: $0)
                                    .textSelection(.enabled)
                            }
                            .listRowSeparator(.hidden)
                            PostBottomPanelView(post: post)
                                .id(post.comments_count + post.rate)
                        }
                    } else {
                        VStack {
                            PostTopPanelView(post: .samplePost)
                            Text("Sample post")
                                .font(.system(size: 20, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .listRowSeparator(.hidden)
                            ForEach(Post.samplePost.blocks, id: \.self) {
                                PostBlockView(block: $0)
                                    .textSelection(.enabled)
                            }
                            .listRowSeparator(.hidden)
                            PostBottomPanelView(post: .samplePost)
                        }
                        .redacted(reason: postDownloaded ? [] : .placeholder)
                    }
                    Group {
                        ForEach(provider.visibles) { comment in
                            SingleCommentView(comment: comment)
                                .id(comment.id)
                                .listRowSeparator(.hidden)
                                .background(Color.clear)
                                .listRowBackground(comment.id == provider.highlightedComment ? Color.gray.opacity(0.1) : nil)
                        }
                        .environmentObject(provider)
                    }
                    
                    Rectangle()
                        .opacity(0)
                        .frame(height: commentEditorHeight)
                }
                .onChange(of: provider.commentDict.count) {
                    withAnimation {
                        proxy.scrollTo(provider.highlightedComment, anchor: .top)
                    }
                }
                .onChange(of: provider.highlightedComment) {
                    withAnimation {
                        proxy.scrollTo(provider.highlightedComment, anchor: .top)
                    }
                }
                .refreshable {
                    Task {
                        do {
                            let fetchedPost = try await Web.shared.fetchPost(id: provider.postId)
                            provider.post = fetchedPost
                            try await provider.fetchComments()
                        } catch {
                            
                        }
                    }
                }
            }
            .listStyle(.grouped)
            VStack {
                if !provider.newComments.isEmpty {
                    Button {
                        provider.parseNewComment()
                    } label: {
                        Text("+ \(provider.newComments.count) новых комментариев")
                            .font(.caption2)
                            .padding(5)
                            .background(Color.init(.systemBackground).cornerRadius(10))
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.black, style: StrokeStyle(lineWidth: 1.0)))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                CommentEditorPanelView(commentEditorText: $commentEditorText, postComment: { text in
                    Task {
                        try await provider.postComment(body: text)
                    }
                })
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: {
                    self.commentEditorHeight = $0.height
                }
                .environmentObject(provider)
            }
        }
        .task {
            do {
                try await provider.fetchPost()
                self.postDownloaded = true
                
                if !commentsDownloaded {
                    try await provider.fetchComments()
                    self.commentsDownloaded = true
                }
            } catch {
                
            }
        }
    }
}
