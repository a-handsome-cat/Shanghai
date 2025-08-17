import SwiftUI

struct TelegramPostView: View {
    @State var post: TelegramPost?
    @State var text: Text = Text("")
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let post = post {
                HStack {
                    if let avatar = post.avatar{
                        AsyncImage(url: avatar) { img in
                            img
                                .resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(.circle)
                        } placeholder: {
                            Circle()
                                .foregroundStyle(.gray)
                                .frame(width: 32, height: 32)
                        }
                    }
                    Text(post.author)
                        .font(.headline)
                    Spacer()
                    Image("tgLogo")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                if !post.media.isEmpty {
                    GalleryView(images: Gallery(height: nil, images: post.media))
                }
                if text != Text("") {
                    text
                }
                HStack {
                    Text("\(post.url)")
                    Spacer()
                    Text(post.timestamp)
                }
                .font(.footnote)
                .lineLimit(1)
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
        .task {
            if self.text == Text(""), let fetchedText = post?.text {
                for element in fetchedText {
                    switch element {
                    case .text(let string):
                        self.text = self.text + Text(.init(string))
                    case .image(let emojiData, let originalEmoji):
                        if let emojiData = emojiData, let emoji = getEmojiImage(data: emojiData) {
                            self.text = self.text + Text(Image(uiImage: emoji))
                        } else {
                            self.text = self.text + Text(originalEmoji)
                        }
                    }
                }
            }
        }
    }
    
    func getEmojiImage(data: Data) -> UIImage? {
        guard let uiImage = UIImage(data: data) else { return nil }
        let textImageSize = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(textImageSize, false, 0.0)
        uiImage.draw(in: CGRect(origin: .zero, size: textImageSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
