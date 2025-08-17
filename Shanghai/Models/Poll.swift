import Foundation

struct Poll: Codable, Hashable, Identifiable {
    let id: Int
    let header: String
    var voted: [Int]
    let variants: [PollVariant]
}

struct PollVariant: Codable, Hashable, Identifiable {
    let id: Int
    let label: String
    let votes_count: Int?
}
