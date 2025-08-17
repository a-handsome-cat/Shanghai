import SwiftUI

struct FeedView: View {
    @StateObject var provider: FeedViewModel
    @State var currPage = 1
    
    let headerSection: ListHeader?
    
    init(client: Web = Web.shared, type: FeedType, headerSection: ListHeader? = nil) {
        _provider = StateObject(wrappedValue: FeedViewModel(client: client, type: type))
        self.headerSection = headerSection
    }
    
    var body: some View {
        if provider.posts.isEmpty {
            VStack {
                List(1...5, id: \.self) { _ in
                    Section {
                        FeedPostView(post: .samplePost)
                    }
                }
                .listStyle(.grouped)
                .redacted(reason: .placeholder)
                .task {
                    do {
                        try await provider.fetchPosts(page: currPage)
                    } catch {
                        
                    }
                    
                }
            }
        } else {
            List {
                if let headerSection = headerSection {
                    headerSection
                }
                ForEach($provider.posts) { $post in
                    Section {
                        FeedPostView(post: post)
                            .background {
                                Color.clear
                                    .contentShape(Rectangle())
                            }
                            .onTapGesture {
                                NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.post(post))
                            }
                            .task {
                                if post == provider.posts.last {
                                    do {
                                        currPage += 1
                                        try await provider.fetchMorePosts(page: currPage)
                                    } catch {
                                        
                                    }
                                }
                            }
                    }
                }
                HStack {
                    Spacer()
                    ProgressView("МИНУТОЧКУ, ВАС МНОГО, А Я ОДНА")
                    Spacer()
                }
            }
            .listStyle(.grouped)
            .ignoresSafeArea(headerSection?.headerImageURL == nil ? [] : .all)
            .refreshable {
                do {
                    currPage = 1
                    try await provider.fetchPosts(page: currPage)
                } catch {
                    
                }
            }
        }
    }
}
