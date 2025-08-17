import SwiftUI
import SocketIO

@MainActor
class PostViewModel: ObservableObject {
    @Published var post: Post?
    let postId: Int
    
    @Published var commentToAnswer: Comment? = nil
    @Published var highlightedComment: Int?
    
    @Published var commentDict: [Int:Comment] = [:]
    @Published var topLevelComments: [Comment] = []
    
    @Published var newComments: [Comment] = []
    
    @AppStorage("xcsrf") private var xcsrf = ""
    @AppStorage("bearer") private var bearer = ""
    
    var visibles: [Comment] {
        var comments: [Comment] = []
        
        func addChildren(of node: Comment, lvl: Int) {
            for child in node.children {
                    let node = commentDict[child]!
                node.level = lvl
                    comments.append(node)
                addChildren(of: commentDict[child]!, lvl: lvl+1)
                }
        }
        
        for comment in topLevelComments {
            comments.append(comment)
            addChildren(of: comment, lvl: 1)
        }
        
        return comments
    }
    
    let socketManager: SocketManager
    let socket: SocketIOClient
    
    deinit {
        socket.disconnect()
    }
    
    init(client: Web = Web.shared, post: Post? = nil, postId: Int, highlightedComment: Int? = nil) {
        self.post = post
        self.postId = postId
        self.highlightedComment = highlightedComment
        
        self.client = client
        self.socketManager = SocketManager(socketURL: URL(string: "https://\(BaseURL.baseURLString)/")!, config: [
            .version(.two),
            .reconnects(false),
            .forceWebsockets(true),
        ]
        )
        self.socket = socketManager.defaultSocket
        
        socket.on(clientEvent: .connect) { [weak self] ack, emitter in
            self?.socket.emit("subscribe", ["channel":"private-post.\(postId)", "auth":["headers":["Authorization":self?.bearer, "X-CSRF-TOKEN":self?.xcsrf]]])
        }
        
        socket.on("CommentAdded") { [weak self] data, ack in
                        for obj in data {
                            if let dict = obj as? [String:Any] {
                                if let comment = dict["comment"] as? [String: Any] {
                                    do {
                                        let data = try JSONSerialization.data(withJSONObject: comment, options: [])
                                        let comm = try JSONDecoder.withFractionalSeconds.decode(Comment.self, from: data)
                                        if self?.commentDict[comm.id] == nil {
                                            self?.newComments.append(comm)
                                        }
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
        }
        
        socket.on("CommentRated") { [weak self] data, ack in
                        for obj in data {
                            if let dict = obj as? [String:Any] {
                                if let comment = dict["comment"] as? [String: Any] {
                                    do {
                                        let data = try JSONSerialization.data(withJSONObject: comment, options: [])
                                        let comm = try JSONDecoder.withFractionalSeconds.decode(Comment.self, from: data)
                                        self?.commentDict[comm.id]?.rate = comm.rate
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
        }
        
        socket.on("CommentUpdated") { [weak self] data, ack in
                        for obj in data {
                            if let dict = obj as? [String:Any] {
                                if let comment = dict["comment"] as? [String: Any] {
                                    do {
                                        let data = try JSONSerialization.data(withJSONObject: comment, options: [])
                                        let comm = try JSONDecoder.withFractionalSeconds.decode(Comment.self, from: data)
                                        self?.commentDict[comm.id] = comm
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
                        }
        }
        
        socket.on("PostRated") { [weak self] data, ack in
                        for obj in data {
                            if let dict = obj as? [String:Any] {
                                if let newRate = dict["rating"] as? Int {
                                    self?.post?.rate = newRate
                                }
                            }
                        }
        }
        
        socket.connect()
    }
    
    let client: Web
    
    func fetchPost() async throws {
        self.post = try await client.fetchPost(id: postId)
    }
    
    func fetchComments() async throws {
        let comments = try await client.fetchComments(id: postId)
        
        var dict: [Int:Comment] = [:]
        
        for comment in comments {
            if let images = comment.images {
                do {
                    for image in images {
                        try await client.fetchImageData(image)
                    }
                } catch {
                    
                }
            }
            
            dict[comment.id] = comment
            if comment.parentId == 0 {
                self.topLevelComments.append(comment)
            }
        }
        
        for comment in comments {
            if let parentComment = dict[comment.parentId] {
                parentComment.children.append(comment.id)
            }
        }
        
        self.commentDict = dict
    }
    
    func postComment(body: String) async throws {
        //guard let post = post else { return }
        
        let response = try await client.postComment(
            postId: self.postId,
            parentComment: commentToAnswer == nil ? 0 : commentToAnswer!.id,
            body: body,
            images: []
        )
        
        if let response = response {
            self.commentDict[response.id] = response
            if response.parentId == 0 {
                self.topLevelComments.append(response)
            } else if let parent = commentDict[response.parentId] {
                parent.children.append(response.id)
            }
            
            self.highlightedComment = response.id
        }
        
        self.commentToAnswer = nil
    }
    
    func parseNewComment() {
        let commNode = newComments.removeFirst()
        
        self.commentDict[commNode.id] = commNode
        if commNode.parentId == 0 {
            self.topLevelComments.append(commNode)
        } else {
            self.commentDict[commNode.parentId]?.children.append(commNode.id)
        }
        
        self.highlightedComment = commNode.id
    }
    
}
