import SwiftUI

struct SingleCommentView: View {
    @EnvironmentObject var provider: PostViewModel
    @ObservedObject var comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: comment.ava) { img in
                    img
                        .resizable()
                        .clipShape(.circle)
                        .frame(width: 26, height: 26)
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .foregroundStyle(Color.gray)
                        .frame(width: 26, height: 26)
                        .clipShape(.circle)
                        .overlay {
                            ProgressView()
                                .frame(width: 20, height: 20)
                        }
                }
                Button {
                    NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.profile(comment.authorId))
                } label: {
                    Text(comment.author)
                        .font(.system(size: 13, weight: .bold))
                }
                .buttonStyle(PlainButtonStyle())
                if comment.parentId != 0 {
                    Button {
                        provider.highlightedComment = comment.parentId
                    } label: {
                        Text("↑")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                Text(comment.date.formatTimestamp())
                    .font(.system(size: 13, weight: .thin))
            }
            Text(.init(comment.body))
            if let images = comment.images, !images.isEmpty {
                GalleryView(images: Gallery(height: nil, images: images))
            }
            HStack {
                Button {
                    provider.commentToAnswer = comment
                } label: {
                    Text("Ответить")
                        .foregroundStyle(.gray)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
                Spacer()
                Button {
                    vote(.down)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(comment.voted ?? 0 < 0 ? Color.red : Color.gray)
                        .bold(comment.voted ?? 0 == -1)
                }
                .buttonStyle(.plain)
                Text("\(comment.rate)")
                    .foregroundStyle(comment.rate==0 ? Color.gray : (comment.rate > 0 ? Color.green : Color.red))
                Button {
                    vote(.up)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundStyle(comment.voted ?? 0 > 0 ? Color.green : Color.gray)
                        .bold(comment.voted ?? 0 == 1)
                }
                .buttonStyle(.plain)
            }
            .font(.system(.footnote))
        }
        .padding([.leading], min(60, CGFloat(comment.level*15)))
        .id(comment.id)
    }
    
    func vote(_ to: Vote) {
        var voted: Int? = nil
        var rateChange = 0
        switch (to, comment.voted) {
        case (.up, 1):
            rateChange = -1
            voted = nil
        case (.up, nil):
            rateChange = +1
            voted = 1
        case (.up, -1):
            rateChange = +2
            voted = 1
        case (.down, 1):
            rateChange = -2
            voted = -1
        case (.down, nil):
            rateChange = -1
            voted = -1
        case (.down, -1):
            rateChange = 1
            voted = nil
        default:
            voted = nil
        }
        comment.rate += rateChange
        comment.voted = voted
        Task {
            try await Web.shared.voteComment(newRate: voted ?? 0, id: comment.id)
        }
    }
}
