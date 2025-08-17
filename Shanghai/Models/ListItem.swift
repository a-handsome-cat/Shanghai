import Foundation

class ListItem: Codable, Hashable {
    let content: String
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decoded = try container.decode(String.self, forKey: .content)
        self.content = decoded.parseHtmlTags()
    }
    
    static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.content == rhs.content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
}
