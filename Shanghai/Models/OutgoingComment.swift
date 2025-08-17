import Foundation

struct OutgoingComment: Codable {
    let parent_id: Int
    let body: String
    let images: [String]
}
