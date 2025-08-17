import SwiftUI

struct CommentsSectionView: View {
    @StateObject var node: Comment
    let lvl: Int
    @State var hideChildren = false
    @EnvironmentObject var provider: PostViewModel

    var body: some View {
        LazyVStack(alignment: .leading) {
            SingleCommentView(comment: node)
                .id(node.id)
            if !node.children.isEmpty && !hideChildren {
                ForEach(node.children, id: \.self) { child in
                    CommentsSectionView(node: provider.commentDict[child]!, lvl: lvl+1)
                        .padding(.leading, lvl < 4 ? 20 : 0)
                }
            }
        }
    }
}
