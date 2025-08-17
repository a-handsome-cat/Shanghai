import SocketIO
import SwiftUI

class TimelineSocket: ObservableObject {
    let socketManager: SocketManager
    let socket: SocketIOClient
    
    @Published var commentsDict: [Int:Comment] = [:]
    @Published var comments: [Int] = []
    
    @AppStorage("xcsrf") private var xcsrf = ""
    @AppStorage("bearer") private var bearer = ""
    
    static let shared = TimelineSocket()
    
    init() {
        self.socketManager = SocketManager(socketURL: URL(string: "https://\(BaseURL.baseURLString)/")!, config: [
            .version(.two),
            .reconnects(false),
            .forceWebsockets(true),
        ]
        )
        self.socket = socketManager.defaultSocket
        
        socket.on("TimelineItem") { [weak self] data, ack in
            for obj in data {
                if let dict = obj as? [String:Any] {
                    if let comment = dict["notification"] as? [String: Any] {
                        do {
                            let data = try JSONSerialization.data(withJSONObject: comment, options: [])
                            let comm = try JSONDecoder.withFractionalSeconds.decode(Comment.self, from: data)
                            
                            if let _ = self?.commentsDict[comm.id] {
                                self?.commentsDict[comm.id] = comm
                            } else {
                                self?.commentsDict[comm.id] = comm
                                self?.comments.insert(comm.id, at: 0)
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        
        socket.on(clientEvent: .connect) { [weak self] data, ack in
            self?.socket.emit("subscribe", ["channel":"private-timeline", "auth":["headers":["Authorization":self?.bearer, "X-CSRF-TOKEN":self?.xcsrf]]])
        }
    }
}
