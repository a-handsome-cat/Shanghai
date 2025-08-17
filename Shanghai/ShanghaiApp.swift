import SwiftUI

@main
struct ShanghaiApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.openURL, OpenURLAction { url in
                    guard url.host(percentEncoded: true) == nil else { return .systemAction }
                    
                    switch url.pathComponents[1] {
                    case "u":
                        guard let userId = Int(url.pathComponents[2]) else {
                            return .systemAction
                        }
                        NavigationCoordinator.shared.paths[NavigationCoordinator.shared.selectedTab]?.append(Screen.profile(userId))
                        return .handled
                    default:
                        return .systemAction
                    }
                })
        }
    }
}
