import Foundation

class Author: Decodable, Hashable, Identifiable, ObservableObject {
    let id: Int
    let name: String
    let ava: URL?
    
    init(id: Int, name: String, ava: URL?) {
        self.id = id
        self.name = name
        self.ava = ava
    }
    
    static func == (lhs: Author, rhs: Author) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
