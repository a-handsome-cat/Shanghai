import SwiftUI

enum Vote {
    case up, down
}

struct PostBottomPanelView: View {
    @ObservedObject var post: Post
    var body: some View {
        HStack {
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "bubble.left")
                        .foregroundStyle(Color.gray)
                    Text("\(post.comments_count)")
                        .foregroundStyle(Color.gray)
                }
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            Button {
                vote(.down)
            } label: {
                Image(systemName: "chevron.down")
                    .foregroundStyle(post.voted ?? 0 < 0 ? Color.red : Color.gray)
                    .bold(post.voted ?? 0 == -1)
            }
            .buttonStyle(PlainButtonStyle())
            Text("\(post.rate)")
                .foregroundStyle(post.rate==0 ? Color.gray : (post.rate > 0 ? Color.green : Color.red))
            Button {
                vote(.up)
            } label: {
                Image(systemName: "chevron.up")
                    .foregroundStyle(post.voted ?? 0 > 0 ? Color.green : Color.gray)
                    .bold(post.voted ?? 0 == 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    func vote(_ to: Vote) {
        var voted: Int? = nil
        var rateChange = 0
        switch (to, post.voted) {
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
        post.rate += rateChange
        post.voted = voted
        Task {
            try await Web.shared.votePost(newRate: voted ?? 0, id: post.id)
        }
    }
}
