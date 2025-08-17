import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let ava: URL?
    let cov: URL?
    let rating: Int
    let subscribers_count: Int
    let registered: String
}
