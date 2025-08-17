import Foundation

class Comment: Decodable, ObservableObject, Identifiable, Hashable {
    var id: Int
    var author: String
    var authorId: Int
    var ava: URL?
    var parentId: Int
    var body: String
    var bodyShort: String
    var images: [ImageData]?
    var date: Date
    var level: Int
    var postId: Int
    var postHeader: String
    @Published var rate: Int
    @Published var voted: Int?
    @Published var children: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, author, body, media, date, rate, voted, post
        case bodyShort = "body_short"
        case parentId = "parent_comment_id"
        case postId = "post_id"
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        let author = try container.decode(Author.self, forKey: .author)
        self.author = author.name
        self.authorId = author.id
        self.ava = author.ava
        self.parentId = try container.decodeIfPresent(Int.self, forKey: .parentId) ?? 0
        self.body = try container.decodeIfPresent(String.self, forKey: .body)?.parseHtmlTags() ?? ""
        self.bodyShort = try container.decodeIfPresent(String.self, forKey: .bodyShort) ?? ""
        self.images = try container.decodeIfPresent([ImageData].self, forKey: .media)
        self.date = try container.decode(Date.self, forKey: .date)
        self.level = 0
        self.postId = try container.decode(Int.self, forKey: .postId)
        let post = try container.decodeIfPresent(PostShortInfo.self, forKey: .post)
        self.postHeader = post?.header ?? ""
        self.rate = try container.decodeIfPresent(Int.self, forKey: .rate) ?? 0
        let voted = try container.decodeIfPresent(VotedType.self, forKey: .voted)
        switch voted {
        case .emptyDictionary:
            self.voted = 0
        case .object(let vote):
            self.voted = vote
        case .none:
            self.voted = 0
        }
        self.children = []
    }
    
    init(id: Int, author: Author, parentId: Int = 0, body: String = "", bodyShort: String = "", images: [ImageData]? = nil, date: Date, level: Int = 0, postId: Int, postHeader: String = "", rate: Int = 0, voted: Int? = nil, children: [Int] = []) {
        self.id = id
        self.author = author.name
        self.authorId = author.id
        self.ava = author.ava
        self.parentId = parentId
        self.body = body.parseHtmlTags()
        self.bodyShort = bodyShort
        self.images = images
        self.date = date
        self.level = level
        self.postId = postId
        self.postHeader = postHeader
        self.rate = rate
        self.voted = voted
        self.children = children
    }
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//Если пользователь ставил оценку комменту, то voted содержит Int, в ином случае - пустой словарь. Так в API.
enum VotedType: Codable, Hashable {
    case object(Int)
    case emptyDictionary
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let object = try? container.decode(Int.self) {
            self = .object(object)
        } else if let _ = try? container.decode(Dictionary<String,Int>.self) {
            self = .emptyDictionary
        } else {
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unexpected type for VotedType"))
        }
    }
}
