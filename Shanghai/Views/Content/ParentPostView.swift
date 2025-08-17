import SwiftUI

struct ParentPostView: View {
    let parent: Post
    var body: some View {
        VStack(alignment: .leading) {
            Text("Ответ на пост:")
                .font(.callout)
                .bold()
            HStack {
                AsyncImage(url: parent.author.ava) { image in
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
                        Text(parent.author.name)
                            .font(.system(size: 13, weight: .bold))
                        Spacer()
                        Text(parent.date.formatTimestamp())
                            .font(.system(size: 13, weight: .thin))
                    }
                }
            }
            Text(parent.header.isEmpty ? "Запись без заголовка" : parent.header)
        }
        .padding()
        .background(Color.init(.secondarySystemBackground).cornerRadius(20))
    }
}
