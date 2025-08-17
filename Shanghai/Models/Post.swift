import Foundation

class Post: Decodable, Hashable, Identifiable, ObservableObject {
    let id: Int
    let header: String
    var preview: [PostBlock]
    @Published var blocks: [PostBlock]
    let author: Author
    let channel: Channel?
    @Published var comments_count: Int
    @Published var rate: Int
    let read_more: Bool
    @Published var date: Date
    let adult_content: Bool
    @Published var voted: Int?
    let parent: Post?
    
    enum CodingKeys: String, CodingKey {
        case id, header, preview, blocks, author, channel, comments_count, rate, read_more, date, adult_content, voted, parent
    }
    
    init(id: Int, header: String, preview: [PostBlock], blocks: [PostBlock], author: Author, channel: Channel?, comments_count: Int, rate: Int, read_more: Bool, date: Date, adult_content: Bool, voted: Int? = nil, parent: Post?) {
        self.id = id
        self.header = header
        self.preview = preview
        self.blocks = blocks
        self.author = author
        self.channel = channel
        self.comments_count = comments_count
        self.rate = rate
        self.read_more = read_more
        self.date = date
        self.adult_content = adult_content
        self.voted = voted
        self.parent = parent
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.header = try container.decode(String.self, forKey: .header)
        self.preview = try container.decode([PostBlock].self, forKey: .preview)
        self.blocks = try container.decode([PostBlock].self, forKey: .blocks)
        self.author = try container.decode(Author.self, forKey: .author)
        self.channel = try container.decodeIfPresent(Channel.self, forKey: .channel)
        self.comments_count = try container.decode(Int.self, forKey: .comments_count)
        self.rate = try container.decode(Int.self, forKey: .rate)
        self.read_more = try container.decode(Bool.self, forKey: .read_more)
        self.date = try container.decode(Date.self, forKey: .date)
        self.adult_content = try container.decode(Bool.self, forKey: .adult_content)
        self.voted = try? container.decode(Int.self, forKey: .voted)
        self.parent = try? container.decode(Post.self, forKey: .parent)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
