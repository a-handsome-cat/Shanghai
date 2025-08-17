import SwiftUI

struct NavigationView<Content: View>: View {
    let tab: Tab
    let content: () -> Content
    @ObservedObject var coordinator = NavigationCoordinator.shared
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { coordinator.paths[tab] ?? NavigationPath() },
            set: { coordinator.paths[tab] = $0 }
        )) {
            content()
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .profile(let id):
                        UserProfileView(id: id)
                    case .postWithId(let id):
                        PostView(id: id)
                    case .postWithComment(let postID, let commentId):
                        PostView(id: postID, highlightedComment: commentId)
                    case .channel(let channelID):
                        ChannelView(id: channelID)
                    case .post(let post):
                        PostView(post: post)
                    }
                }
        }
    }
}
