import SwiftUI

struct PostTopPanelView: View {
    let post: Post
    
    var body: some View {
        HStack {
            AsyncImage(url: post.author.ava) { image in
                image
                    .resizable()
                    .frame(width: 26, height: 26)
                    .clipShape(.circle)
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
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.profile(post.author.id))
                    } label: {
                        Text(post.author.name)
                            .font(.system(size: 13, weight: .bold))
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                    Text(post.date.formatTimestamp())
                        .font(.system(size: 13, weight: .thin))
                }
                if let channel = post.channel {
                    Button {
                        NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.channel(channel.id))
                    } label: {
                        Text(channel.name)
                            .font(.system(size: 13, weight: .regular))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
