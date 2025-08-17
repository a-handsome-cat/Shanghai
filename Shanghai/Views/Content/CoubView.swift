import SwiftUI
import SwiftSoup

struct CoubView: View {
    let url: URL
    let img: URL
    var body: some View {
        VStack {
            Link(destination: url) {
                ZStack {
                    AsyncImage(url: img) { image in
                        image
                            .resizable()
                            .frame(maxHeight: 400)
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(Color.black)
                            .frame(width: 200, height: 200)
                            .overlay {
                                ProgressView()
                            }
                    }
                    Circle()
                        .foregroundStyle(.blue)
                        .frame(height: 80)
                    Image(systemName: "hand.point.up")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            Text("\(url)")
                .foregroundStyle(.gray)
                .font(.footnote)
        }
    }
}
