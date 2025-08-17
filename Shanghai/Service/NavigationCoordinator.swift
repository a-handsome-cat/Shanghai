import SwiftUI

enum Tab {
    case feed
    case live
    case notifications
    case profile
}

enum Screen: Hashable {
    case postWithId(Int)
    case postWithComment(Int, Int)
    case post(Post)
    case profile(Int)
    case channel(Int)
}

class NavigationCoordinator: ObservableObject {
    @Published var paths: [Tab:NavigationPath] = [
        .feed:NavigationPath(),
        .live:NavigationPath(),
        .notifications:NavigationPath(),
        .profile:NavigationPath()
    ]
    @Published var selectedTab: Tab = .feed
    static let shared = NavigationCoordinator()
}
