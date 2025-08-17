import Foundation

class ImageData: Codable, Hashable, Identifiable {
    let url: URL
    var width: CGFloat?
    var height: CGFloat?
    
    var localDataURL: URL?
    
    let id: UUID = UUID()
    
    init(url: URL, width: CGFloat? = nil, height: CGFloat? = nil) {
        self.url = url
        self.width = width
        self.height = height
    }
    
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
