import SwiftUI

struct YoutubeEmbedView: View {
    var url: URL
    var cover: URL
    var body: some View {
        VStack {
            Link(destination: url) {
                ZStack {
                    AsyncImage(url: cover) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(Color.black)
                            .frame(width: 200, height: 200)
                            .overlay {
                                ProgressView()
                            }
                    }
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.white, .red)
                }
            }
            .buttonStyle(PlainButtonStyle())
            Text("\(url)")
                .foregroundStyle(.gray)
                .font(.footnote)
        }
    }
}
