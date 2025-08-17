import Foundation

class BlockData: Codable, Hashable {
    let blockDataID = UUID()
    
    let text: String?
    let images: Gallery?
    let embed: String?
    let service: String?
    let url: URL?
    let cover: URL?
    let caption: String?
    let variants: [PollVariant]?
    let id: Int?
    let source: URL?
    let img: URL?
    let level: Int?
    let quote: String?
    let style: String?
    let items: [ListItem]?
    
    var telegramPost: TelegramPost?
    var odesliData: Odesli?
    
    init(text: String?, images: Gallery?, embed: String?, service: String?, url: URL?, cover: URL?, caption: String?, header: String?, variants: [PollVariant]?, id: Int?, source: URL?, img: URL?, level: Int?, quote: String?, style: String?, items: [ListItem]?) {
        self.text = text
        self.images = images
        self.embed = embed
        self.service = service
        self.url = url
        self.cover = cover
        self.caption = caption
        self.variants = variants
        self.id = id
        self.source = source
        self.img = img
        self.level = level
        self.quote = quote
        self.style = style
        self.items = items
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.text = try container.decodeIfPresent(String.self, forKey: .text)?.parseHtmlTags()
        let images = try container.decodeIfPresent([ImageData].self, forKey: .images)
        if let images = images {
            self.images = Gallery(height: nil, images: images)
        } else {
            self.images = nil
        }
        self.embed = try container.decodeIfPresent(String.self, forKey: .embed)
        self.service = try container.decodeIfPresent(String.self, forKey: .service)
        self.url = try container.decodeIfPresent(URL.self, forKey: .url)
        self.cover = try container.decodeIfPresent(URL.self, forKey: .cover)
        self.caption = try container.decodeIfPresent(String.self, forKey: .caption)
        self.variants = try container.decodeIfPresent([PollVariant].self, forKey: .variants)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.source = try container.decodeIfPresent(URL.self, forKey: .source)
        self.img = try container.decodeIfPresent(URL.self, forKey: .img)
        self.level = try container.decodeIfPresent(Int.self, forKey: .level)
        self.quote = try container.decodeIfPresent(String.self, forKey: .quote)
        self.style = try container.decodeIfPresent(String.self, forKey: .style)
        self.items = try container.decodeIfPresent([ListItem].self, forKey: .items)
        self.telegramPost = try container.decodeIfPresent(TelegramPost.self, forKey: .telegramPost)
        self.odesliData = try container.decodeIfPresent(Odesli.self, forKey: .odesliData)
    }
    
    static func == (lhs: BlockData, rhs: BlockData) -> Bool {
        lhs.blockDataID == rhs.blockDataID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(blockDataID)
    }
}
