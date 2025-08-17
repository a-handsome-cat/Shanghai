import SwiftUI

struct NotificationsView: View {
    @ObservedObject var viewModel = NotificationsViewModel.shared
    
    var body: some View {
            ScrollView {
                VStack {
                    ForEach(viewModel.notifications) { notification in
                        VStack(alignment: .leading) {
                            Button {
                                if let postId = notification.data.post?.id {
                                    if let commentId = notification.data.comment.id {
                                        NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.postWithComment(postId, commentId))
                                    } else {
                                        NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.postWithId(postId))
                                    }
                                }
                            } label: {
                                getView(notification)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider()
                        }
                        .background(notification.read ? nil : Color.blue.opacity(0.3).cornerRadius(10))
                    }
                }
            }
            .navigationTitle("")
            .onAppear {
                viewModel.newNotifications = 0
                Task {
                    await viewModel.update()
                    do {
                        try await Web.shared.markNotificationsAsRead()
                    } catch {
                        
                    }
                }
            }
            .refreshable {
                viewModel.newNotifications = 0
                Task {
                    await viewModel.update()
                    do {
                        try await Web.shared.markNotificationsAsRead()
                    } catch {
                        
                    }
                }
            }
        
    }
    
    func getImg(_ notification: Notification) -> (Image, Color) {
        switch notification.type {
        case "comment_like", "post_like":
            switch notification.data.rate {
            case 1:
                (Image("chevron-up"), .green)
            case -1:
                (Image("chevron-down"), .red)
            default:
                (Image(systemName: "smallcircle.filled.circle"), .gray)
            }
        case "comment_reply", "post_comment":
            (Image("reply-fill"), .blue)
        case "post_reply":
            (Image("chat-left-text-fill"), .purple)
        case "subscriber_added":
            (Image("check-circle-fill"), .blue)
        case "user_mentioned":
            (Image("at"), .yellow)
        default:
            (Image(systemName: "smallcircle.filled.circle"), .gray)
        }
    }
    
    @ViewBuilder
    func getView(_ notification: Notification) -> some View {
        let (image, color) = getImg(notification)
        HStack {
            image
                .resizable()
                .frame(width: 15, height: 15)
                .padding()
                .background {
                    Circle()
                        .frame(width: 30)
                        .foregroundStyle(color)
                }
            
            Text(.init(notification.message.parseHtmlTags()))
                .font(.callout)
            Spacer()
        }
        .padding(5)
    }
}
