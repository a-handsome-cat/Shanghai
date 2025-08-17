import SwiftUI

struct LivecastView: View {
    @ObservedObject var timeline = TimelineSocket.shared
    var body: some View {
        List(timeline.comments, id: \.self) { id in
            let comment = timeline.commentsDict[id]!
            Button {
                NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.postWithComment(comment.postId, comment.id))
            } label: {
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
                        Text(comment.author)
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text(comment.date.formatTimestamp())
                            .font(.system(size: 13, weight: .thin))
                    }
                    Text(comment.bodyShort)
                    Text(comment.postHeader.isEmpty ? "Запись без заголовка" : comment.postHeader)
                        .bold()
                        .padding([.top])
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .onAppear {
            Task {
                do {
                    let comms = try await Web.shared.fetchTimeline()
                    timeline.commentsDict = Dictionary(uniqueKeysWithValues: comms.map { ($0.id, $0) } )
                    timeline.comments = comms.map { $0.id }
                } catch {
                    
                }
                timeline.socket.connect()
            }
        }
        .onDisappear {
            timeline.socket.disconnect()
        }
    }
}
