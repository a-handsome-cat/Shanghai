import Foundation

enum FeedSort: CodingKey {
    case fresh, popular, feed, best, old, worst
    
    var description: String {
        switch self {
        case .fresh:
            "Свежее"
        case .popular:
            "Популярное"
        case .feed:
            "Моя лента"
        case .best:
            "Лучшее"
        case .old:
            "Старое"
        case .worst:
            "Худшее"
        }
    }
}

enum FeedType: Hashable {
    case feed(FeedSort)
    case channel(Int, FeedSort)
    case user(Int, FeedSort)
}

enum NetworkError: Error {
    case connectionError, invalidURL, dataCorrupted, decodingError, valueNotFound, typeMismatch, unknownError
}

class Web {
    enum APIMethod {
        case feed(type: FeedType, page: Int)
        case post(id: Int)
        case postComments(id: Int)
        case timeline
        case channelInfo(id: Int)
        case poll(id: Int)
        case userInfo(id: Int)
        case notifications
        case postComment(id: Int)
        case votePoll(id: Int)
        case voteComment(id: Int)
        case votePost(id: Int)
        case markNotificationsAsRead
        
        var path: String {
            switch self {
            case .feed(let feedType, let page):
                switch feedType {
                case .feed(let feedSort):
                    "posts?section=\(feedSort.stringValue)&page=\(page)"
                case .channel(let id, let feedSort):
                    "channel/\(id)/posts?page=\(page)&sort=\(feedSort.stringValue)"
                case .user(let id, let feedSort):
                    "user/\(id)/posts?page=\(page)&sort=\(feedSort.stringValue)"
                }
            case .post(let id):
                "posts/\(id)"
            case .postComments(let id):
                "posts/\(id)/comments"
            case .timeline:
                "timeline"
            case .channelInfo(let id):
                "channel/\(id)"
            case .poll(let id):
                "poll/\(id)"
            case .userInfo(let id):
                "user/\(id)"
            case .notifications:
                "notifications"
            case .postComment(let id):
                "posts/\(id)/comments"
            case .votePoll(let id):
                "poll/\(id)"
            case .voteComment(let id):
                "comments/\(id)/rate"
            case .votePost(let id):
                "posts/\(id)/rate"
            case .markNotificationsAsRead:
                "notifications/read"
            }
        }
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    struct APIRequest {
        let apiMethod: APIMethod
        let httpMethod: HTTPMethod
        let body: Data?
    }
    
    static let shared = Web()
    let decoder = JSONDecoder.withFractionalSeconds
    
    func sendAPIRequest<T:Decodable>(_ apiRequest: APIRequest, responseType: T.Type) async throws -> T {
        let baseURL = "https://\(BaseURL.baseURLString)/api/v1.1/"
        
        guard let apiURL = URL(string: baseURL + apiRequest.apiMethod.path) else { throw NetworkError.invalidURL }
        var request = URLRequest(url: apiURL)
        request.httpMethod = apiRequest.httpMethod.rawValue
        
        if let body = apiRequest.body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
            throw NetworkError.dataCorrupted
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw NetworkError.decodingError
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw NetworkError.valueNotFound
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            throw NetworkError.typeMismatch
        } catch {
            print("error: ", error)
            throw NetworkError.unknownError
        }
    }
    
    func fetchFeed(type: FeedType, page: Int) async throws -> [Post] {
        let posts = try await sendAPIRequest(APIRequest(apiMethod: .feed(type: type, page: page), httpMethod: .get, body: nil), responseType: APIDataResponse<[Post]>.self)
        try await fetchPostsContent(posts: posts.data)
        
        return posts.data
    }
    
    func fetchPost(id: Int) async throws -> Post {
        let post = try await sendAPIRequest(APIRequest(apiMethod: .post(id: id), httpMethod: .get, body: nil), responseType: APIDataResponse<Post>.self)
        try await fetchPostsContent(posts: [post.data])
        
        return post.data
    }
    
    func fetchComments(id: Int) async throws -> [Comment] {
        let url = URL(string: "https://\(BaseURL.baseURLString)/api/v1.1/posts/\(id)/comments")!
        
        guard let (data, _) = try await URLSession.shared.data(from: url, delegate: nil) as? (Data, HTTPURLResponse) else {
            throw NetworkError.connectionError
        }
        
        //Единственный комментарий возвращается массивом, если их больше - словарем
        if let commentsResponse = try? decoder.decode(APIDataResponse<[Int:[Comment]]>.self, from: data) {
            return commentsResponse.data.values.reduce([], +)
        } else if let commentsResponse = try? decoder.decode(APIDataResponse<[[Comment]]>.self, from: data) {
            return commentsResponse.data.reduce([], +)
        }
        
        return []
    }
    
    func fetchTimeline() async throws -> [Comment] {
        let timeline = try await sendAPIRequest(APIRequest(apiMethod: .timeline, httpMethod: .get, body: nil), responseType: APIDataResponse<[Comment]>.self)
        return timeline.data
    }
    
    func postComment(postId: Int, parentComment: Int, body: String, images: [String]) async throws -> Comment? {
        let comment = OutgoingComment(parent_id: parentComment, body: body, images: images)
        let encoded = try JSONEncoder().encode(comment)
        
        let decodedResponse = try await sendAPIRequest(APIRequest(apiMethod: .postComment(id: postId), httpMethod: .post, body: encoded), responseType: APIDataResponse<Comment>.self)
        
        return decodedResponse.data
    }
    
    func votePost(newRate: Int, id: Int) async throws {
        let dict = ["rate":newRate]
        let encoded = try JSONEncoder().encode(dict)
        
        let _ = try await sendAPIRequest(APIRequest(apiMethod: .votePost(id: id), httpMethod: .post, body: encoded), responseType: APIDataResponse<Post>.self)
    }
    
    func voteComment(newRate: Int, id: Int) async throws {
        let dict = ["rate":newRate]
        let encoded = try JSONEncoder().encode(dict)
        
        let _ = try await sendAPIRequest(APIRequest(apiMethod: .voteComment(id: id), httpMethod: .post, body: encoded), responseType: APIDataResponse<Comment>.self)
    }
    
    func votePoll(pollId: Int, variantId: Int) async throws -> Poll? {
        let dict = ["variants":[variantId]]
        let encoded = try JSONEncoder().encode(dict)
        
        let response = try await sendAPIRequest(APIRequest(apiMethod: .votePoll(id: pollId), httpMethod: .post, body: encoded), responseType: APIDataResponse<Poll>.self)
        return response.data
    }
    
    func fetchPoll(id: Int) async throws -> Poll {
        let poll = try await sendAPIRequest(APIRequest(apiMethod: .poll(id: id), httpMethod: .get, body: nil), responseType: APIDataResponse<Poll>.self)
        return poll.data
    }
    
    func getTwitterEmbedCode(url: URL) async throws -> String {
        guard let (data, _) = try await URLSession.shared.data(from: URL(string: "https://publish.twitter.com/oembed")!.appending(queryItems: [URLQueryItem(name: "url", value: url.absoluteString)]), delegate: nil) as? (Data, HTTPURLResponse) else {
            throw NetworkError.connectionError
        }
        
        let embed = try decoder.decode(TwitterEmbedModel.self, from: data)
        return embed.html
    }
    
    func getUserInfo(id: Int) async throws -> User? {
        let userInfo = try await sendAPIRequest(APIRequest(apiMethod: .userInfo(id: id), httpMethod: .get, body: nil), responseType: APIDataResponse<User>.self)
        return userInfo.data
    }
    
    func getChannelInfo(id: Int) async throws -> Channel? {
        let channelInfo = try await sendAPIRequest(APIRequest(apiMethod: .channelInfo(id: id), httpMethod: .get, body: nil), responseType: APIDataResponse<Channel>.self)
        return channelInfo.data
    }
    
    func fetchNotifications() async throws -> [Notification] {
        let notifications = try await sendAPIRequest(APIRequest(apiMethod: .notifications, httpMethod: .get, body: nil), responseType: APIDataResponse<[Notification]>.self)
        return notifications.data
    }
    
    func markNotificationsAsRead() async throws {
        let _ = try await sendAPIRequest(APIRequest(apiMethod: .markNotificationsAsRead, httpMethod: .post, body: nil), responseType: [String:Bool].self)
    }
}
