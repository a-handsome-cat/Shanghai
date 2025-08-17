import SwiftUI
import SwiftSoup
import RegexBuilder

enum TelegramTextComponent: Codable, Hashable {
    case text(String)
    case image(Data?, String)
}

class TelegramParser {
    static let shared = TelegramParser()
    
    let tgEmojis = Regex {
        "<tg-emoji emoji-id=\""
        Capture { ZeroOrMore(.digit) }
        "\">"
        ZeroOrMore(.any, .reluctant)
        One("</tg-emoji>")
    }
    
    let imageURLRegex = Regex {
        "background-image:url('"
        Capture { OneOrMore(.any) }
        "')"
    }
    
    func fetchTGPost(url: URL) async throws -> TelegramPost? {
        let postURL = url.appending(queryItems: [URLQueryItem(name: "embed", value: "1")])
        
        let (data, _) = try await URLSession.shared.data(from: postURL)
        
        guard let htmlCode = String(data: data, encoding: .utf8) else { return nil }
        
        let doc: Document = try SwiftSoup.parse(htmlCode)
        
        let avatarString = try doc.getElementsByClass("tgme_widget_message_user").first()?.select("img").attr("src") ?? ""
        let avatar = URL(string: avatarString)
        
        let channel = try doc.getElementsByClass("tgme_widget_message_owner_name")
        let author = try channel.first()?.text() ?? ""
        
        let textElements = try doc.getElementsByClass("tgme_widget_message_text js-message_text").first()
        let rawText = try TagsParser.shared.parseElement(textElements)
        var postText = [TelegramTextComponent]()
        postText = try await parseTelegramText(rawText: rawText)
        
        var mediaLinks: [URL] = []
        
        let photoClass = try doc.getElementsByClass("tgme_widget_message_photo_wrap")
        for c in photoClass {
            let style = try c.attr("style")
            
            if let match = style.firstMatch(of: imageURLRegex) {
                let urlString = String(match.output.1)
                if let url = URL(string: urlString) {
                    mediaLinks.append(url)
                }
            }
        }
        
        let videoClass = try doc.select("video")
        for c in videoClass {
            if let url = URL(string: try c.attr("src")), !mediaLinks.contains(url) {
                mediaLinks.append(url)
            }
        }
        
        var imagesData: [ImageData] = []
        for link in mediaLinks {
            let model = ImageData(url: link)
            try await Web.shared.fetchImageData(model)
            imagesData.append(model)
        }
        
        let timestamp = try doc.getElementsByClass("tgme_widget_message_date").first()?.text() ?? ""
        
        return TelegramPost(avatar: avatar, author: author, text: postText, url: url, media: imagesData, timestamp: timestamp)
    }
    
    private func parseTelegramText(rawText: String) async throws -> [TelegramTextComponent] {
        var output = [TelegramTextComponent]()
        var rawText = rawText
        
        while let match = rawText.firstMatch(of: tgEmojis) {
            let (fullTag, emojiID) = match.output
            let originalEmoji = fullTag.filter { $0.isEmoji }
            
            let parsedText = String(rawText[..<match.range.lowerBound])
            output.append(.text(parsedText))
            let emoji = try await getTelegramEmoji(id: String(emojiID))
            
            output.append(.image(emoji, originalEmoji))
            
            rawText.removeSubrange(..<match.range.upperBound)
        }
        
        output.append(.text(rawText))
        
        return output
    }
    
    private func getTelegramEmoji(id: String) async throws -> Data? {
        guard let url = URL(string: "https://t.me/i/emoji/\(id).json") else { return nil }
        let (data, _) = try await URLSession.shared.data(from: url)
        let emojiInfo = try JSONDecoder().decode(TelegramEmoji.self, from: data)
        
        //При использовании non-ephemeral сессии после некоторого количества запросов начинает вываливаться с ошибкой
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        let (emojiData, _) = try await session.data(from: emojiInfo.emoji)
        guard let _ = UIImage(data: emojiData) else { return nil }
        return emojiData
    }
}
