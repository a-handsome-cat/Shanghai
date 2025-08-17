import SwiftUI

struct MainView: View {
    @AppStorage("loggedIn") private var loggedIn = false
    
    @StateObject var coordinator = NavigationCoordinator.shared
    @StateObject var notificationsSocket = NotificationsViewModel.shared
    @StateObject var audioObserver = AudioObserver.shared
    
    var body: some View {
            TabView(selection: $coordinator.selectedTab) {
                NavigationView(tab: .feed) {
                    FeedsView()
                }
                .tag(Tab.feed)
                .tabItem {
                    Label("Свежее", systemImage: "house.fill")
                }
                if loggedIn {
                    NavigationView(tab: .live) {
                        LivecastView()
                    }
                    .tag(Tab.live)
                    .tabItem {
                        Label("Прямой эфир", systemImage: "tv.badge.wifi")
                    }
                    
                    NavigationView(tab: .notifications) {
                        NotificationsView()
                    }
                    .tabItem {
                        Label("Уведомления", systemImage: "bell.fill")
                    }
                    .badge(notificationsSocket.newNotifications)
                    .tag(Tab.notifications)
                }
                NavigationView(tab: .profile) {
                    ProfileView()
                }
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
                .tag(Tab.profile)
            }
    }
}
