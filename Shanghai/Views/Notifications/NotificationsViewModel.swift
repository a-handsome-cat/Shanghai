import SocketIO
import SwiftUI

@MainActor
class NotificationsViewModel: ObservableObject {
    let socketManager: SocketManager
    let socket: SocketIOClient
    
    @Published var notifications: [Notification] = []
    @Published var newNotifications = 0
    
    @AppStorage("xcsrf") private var xcsrf = ""
    @AppStorage("bearer") private var bearer = ""
    @AppStorage("userID") private var userID = 0
    @AppStorage("loggedIn") private var loggedIn = false
    
    static var shared = NotificationsViewModel()
    
    static func reset() {
        shared = NotificationsViewModel()
    }
    
    init() {
        self.socketManager = SocketManager(socketURL: URL(string: "https://\(BaseURL.baseURLString)/")!, config: [
            .version(.two),
            .reconnects(false),
            .forceWebsockets(true),
        ]
        )
        self.socket = socketManager.defaultSocket
        
        socket.on(#"Illuminate\Notifications\Events\BroadcastNotificationCreated"#) { data, ack in
            self.newNotifications += 1
        }
        
        socket.on(clientEvent: .connect) { data, ack in
            self.socket.emit("subscribe", ["channel":"private-users.\(self.userID)", "auth":["headers":["Authorization":self.bearer, "X-CSRF-TOKEN":self.xcsrf]]])
        }
        
        if self.loggedIn {
            socket.connect()
            
            Task {
                await update()
                self.newNotifications = notifications.reduce(into: 0) { partial, notification in
                    partial += notification.read ? 0 : 1
                }
            }
        }
    }
    
    func update() async {
        do {
            self.notifications = try await Web.shared.fetchNotifications()
        } catch {
            
        }
    }
}
