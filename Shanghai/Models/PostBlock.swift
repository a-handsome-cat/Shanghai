import Foundation

struct PostBlock: Codable, Hashable {
    let type: String
    var data: BlockData
    
    init(type: String, data: BlockData) {
        self.type = type
        self.data = data
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        if let data = try? container.decode(BlockData.self, forKey: .data) {
            self.data = data
        } else {
            self.data = BlockData(text: nil, images: nil, embed: nil, service: nil, url: nil, cover: nil, caption: nil, header: nil, variants: nil, id: nil, source: nil, img: nil, level: nil, quote: nil, style: nil, items: nil)
        }
    }
}
