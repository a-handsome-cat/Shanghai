import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    let type: FeedType
    
    init(client: Web = Web.shared, type: FeedType) {
        self.client = client
        self.type = type
    }
    
    let client: Web
    
    func fetchPosts(page: Int) async throws {
        let fetched = try await client.fetchFeed(type: type, page: page)
        self.posts = fetched
    }
    
    func fetchMorePosts(page: Int) async throws {
        let fetched = try await client.fetchFeed(type: type, page: page)
        if let last = posts.last {
            self.posts += fetched.filter { $0.id < last.id }
        } else {
            self.posts += fetched
        }
        
    }
}
