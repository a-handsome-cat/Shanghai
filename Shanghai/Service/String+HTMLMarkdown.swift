import RegexBuilder
import SwiftSoup

extension String {
    func parseHtmlTags() -> String {
        do {
            let document = try SwiftSoup.parse(self)
            return try TagsParser.shared.parseElement(document.body())
        } catch {
            return self
        }
    }
}

class TagsParser {
    static let shared = TagsParser()
    
    let textWithWhitespaces = Regex {
        Anchor.startOfSubject
        Capture { ZeroOrMore(.whitespace) }
        Capture { ZeroOrMore(.any, .reluctant) }
        Capture { ZeroOrMore(.whitespace) }
        Anchor.endOfSubject
    }
    
    let linkWithStars = Regex {
        Anchor.startOfSubject
        Capture { ZeroOrMore("*") }
        Capture { ZeroOrMore(.any, .reluctant) }
        Capture { ZeroOrMore("*") }
        Anchor.endOfSubject
    }
    
    func parseElement(_ element: Element?) throws -> String {
        guard let element = element else { return "" }
        
        var result = ""
        
        for node in element.getChildNodes() {
            if let textNode = node as? TextNode {
                result += textNode.text()
            } else if let element = node as? Element {
                let inner = try parseElement(element)
                
                if let match = inner.firstMatch(of: textWithWhitespaces) {
                    let (_, leadingWhitespace, coreText, trailingWhitespace) = match.output
                    
                    switch element.tagName() {
                    case "tg-emoji":
                        result += try element.outerHtml()
                    case "b":
                        if result.hasSuffix("*") {
                            result += " "
                        }
                        result += (leadingWhitespace + "**\(coreText)**" + trailingWhitespace)
                    case "i":
                        if result.hasSuffix("*") {
                            result += " "
                        }
                        if element.hasAttr("class") {
                            result += inner
                        } else {
                            result += (leadingWhitespace + (coreText.isEmpty ? "" : "*\(coreText)*") + trailingWhitespace)
                        }
                    case "a":
                        if let linkMatch = coreText.firstMatch(of: linkWithStars) {
                            let output = linkMatch.output
                            let href = try element.attr("href")
                            result += (output.1 + "[\(output.2)](\(href))" + output.3)
                        }
                    case "br":
                        result += "\n"
                    case "div":
                        if element.hasAttr("class"), let classAttr = try? element.attr("class"), classAttr.hasPrefix("comment-quote") {
                            result += "> \(coreText)\n"
                        } else {
                            result += inner
                        }
                    default:
                        result += inner
                    }
                }
            }
        }
        
        return result
    }
}
