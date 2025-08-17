import SwiftUI

struct PostBlockView: View {
    let block: PostBlock
    
    var body: some View {
        if block.type == "paragraph", let str = block.data.text {
            Text(.init(str))
                .frame(maxWidth: .infinity, alignment: .leading)
        } else if block.type == "ImagePlugin" {
            if let images = block.data.images {
                GalleryView(images: images)
            }
            
            if let caption = block.data.caption, !caption.isEmpty {
                Text(.init(caption))
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        } else if block.type == "embed" {
            if let service = block.data.service {
                switch service {
                case "youtube":
                    if let embed = block.data.embed, let url = URL(string: embed), let cover = block.data.cover {
                        YoutubeEmbedView(url: url, cover: cover)
                    }
                case "twitter":
                    if let embed = block.data.source {
                        TwitterEmbedWrapView(url: embed)
                    }
                case "coub":
                    if let embed = block.data.embed, let url = URL(string: embed), let img = block.data.img {
                        CoubView(url: url, img: img)
                    }
                default:
                    Text("Здесь какой-то неучтенный эмбед, сообщите об этом разработчику")
                }
            }
        } else if block.type == "telegram" {
            if let post = block.data.telegramPost {
                TelegramPostView(post: post)
            }
        } else if block.type == "Odesli" {
            if let item = block.data.odesliData {
                OdesliView(item: item)
            }
        } else if block.type == "poll" {
            if let id = block.data.id, let _ = block.data.variants {
                PollView(id: id)
            }
        } else if block.type == "header" {
            if let text = block.data.text, let level = block.data.level {
                var levelFont: Font {
                    switch level {
                    case 1:
                            .title
                    case 2:
                            .title2
                    default:
                            .title3
                    }
                }
                Text(text)
                    .font(levelFont)
                    .bold()
            }
        } else if block.type == "quote", let quote = block.data.quote, let caption = block.data.caption {
            HStack(alignment: .top) {
                Image(systemName: "quote.bubble")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 24))
                VStack(alignment: .trailing) {
                    Text(quote)
                    Text(caption)
                        .font(.caption)
                        .bold()
                }
            }
        } else if block.type == "list", let listStyle = block.data.style, let listItems = block.data.items {
            switch listStyle {
            case "ordered":
                ForEach(listItems.indices, id: \.self) { index in
                    Text(.init("\(index+1). \(listItems[index].content)"))
                }
            default:
                ForEach(listItems, id: \.self) { listItem in
                    Text("• \(listItem.content)")
                }
            }
        } else if block.type == "delimiter" {
            Text("***")
                .font(.title)
                .bold()
        }
        
        
    }
}
