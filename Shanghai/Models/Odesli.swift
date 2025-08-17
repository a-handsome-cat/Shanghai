import Foundation

struct Odesli: Codable {
    let entitiesByUniqueId: [String:OdesliService]
    let linksByPlatform: [String:OdesliLink]
}

struct OdesliService: Codable {
    let id: String
    let title: String
    let artistName: String
    let thumbnailUrl: URL
}

struct OdesliLink: Codable, Hashable {
    let url: URL
    let entityUniqueId: String
}
