import Foundation

struct TelegramPost: Codable {
    let avatar: URL?
    let author: String
    let text: [TelegramTextComponent]
    let url: URL
    let media: [ImageData]
    let timestamp: String
}

struct TelegramEmoji: Codable {
    let emoji: URL
}
