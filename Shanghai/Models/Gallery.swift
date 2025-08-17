import Foundation

struct Gallery: Codable {
    var height: CGFloat?
    let images: [ImageData]
}
