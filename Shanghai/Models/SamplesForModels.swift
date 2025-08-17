import Foundation

extension Post {
    static let samplePost = Post(
        id: 0,
        header: "Post header",
        preview: [.samplePostBlock],
        blocks: [.samplePostBlock],
        author: .sampleAuthor,
        channel: nil,
        comments_count: 0,
        rate: 0,
        read_more: false,
        date: Date(),
        adult_content: false,
        parent: nil
    )
}

extension PostBlock {
    static let samplePostBlock = PostBlock(
        type: "paragraph",
        data: BlockData(
            text: "This is a text post and it's text paragraph",
            images: nil,
            embed: nil,
            service: nil,
            url: nil,
            cover: nil,
            caption: nil,
            header: nil,
            variants: nil,
            id: nil,
            source: nil,
            img: nil,
            level: nil,
            quote: nil,
            style: nil,
            items: nil
        )
    )
}

extension Author {
    static let sampleAuthor = Author(
        id: 0,
        name: "Test Author",
        ava: URL(string: "https://www.gstatic.com/webp/gallery/4.webp")!
    )
}
