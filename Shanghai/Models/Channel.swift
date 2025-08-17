import Foundation

struct Channel: Codable {
    let id: Int
    let name: String
    let description: String?
    let ava: URL?
    let rules: String?
}
