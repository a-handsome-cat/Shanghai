import Foundation

struct Notification: Codable, Identifiable, Hashable {
    let id: UUID
    let type: String
    let data: NotificationData
    let message: String
    let read: Bool
}

struct NotificationData: Codable, Hashable {
    let post: PostShortInfo?
    let comment: NotificationComment
    let rate: Int?
}

struct NotificationComment: Codable, Identifiable, Hashable {
    let id: Int?
}
