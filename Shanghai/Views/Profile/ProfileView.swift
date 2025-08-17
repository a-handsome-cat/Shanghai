import SwiftUI

struct ProfileView: View {
    @State private var showLoginView: Bool = false
    @AppStorage("loggedIn") private var loggedIn = false
    @AppStorage("xcsrf") private var xcsrf = ""
    @AppStorage("bearer") private var bearer = ""
    @AppStorage("userID") private var userID = 0
    
    var body: some View {
        if loggedIn {
            if userID != 0 {
                UserProfileView(id: userID)
                    .ignoresSafeArea(edges: .top)
            } else {
                ProgressView()
            }
        } else {
            List {
                Button {
                    self.showLoginView = true
                } label: {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Войти в профиль")
                    }
                }
            }
            .sheet(isPresented: $showLoginView) {
                LoginWebView(url: URL(string: "https://\(BaseURL.baseURLString)/login")!) { xcsrf, bearer in
                    self.xcsrf = xcsrf
                    self.bearer = bearer
                    
                    Task {
                        do {
                            guard let url = URL(string: "https://\(BaseURL.baseURLString)/api/v1.1/user/data") else { return }
                            guard let (data, _) = try await URLSession.shared.data(from: url, delegate: nil) as? (Data, HTTPURLResponse) else {
                                throw NetworkError.connectionError
                            }
                            let userdata = try JSONDecoder().decode(APIDataResponse<UserOwnInfo>.self, from: data)
                            self.userID = userdata.data.id
                            
                            NotificationsViewModel.reset()
                        } catch {
                            print(error)
                        }
                    }
                    
                    self.showLoginView = false
                    self.loggedIn = true
                }
            }
        }
    }
}
