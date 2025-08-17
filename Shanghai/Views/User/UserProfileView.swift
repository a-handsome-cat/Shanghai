import SwiftUI

struct UserProfileView: View {
    @State var profile: User? = nil
    let id: Int
    @State var feedSort: FeedSort = .fresh
    let feedSorts: [FeedSort] = [.fresh, .old, .best, .worst]
    
    var body: some View {
        if let profile = profile {
            let headerSection = ListHeader(headerAvatarURL: profile.ava, headerImageURL: profile.cov, headerContent: AnyView(header))
            FeedView(type: .user(profile.id, feedSort), headerSection: headerSection)
                .id(feedSort)
        } else {
            ProgressView()
                .task {
                    do {
                        self.profile = try await Web.shared.getUserInfo(id: id)
                    } catch {
                        
                    }
                }
        }
    }
    
    var header: some View {
        VStack {
            if let profile = profile {
                VStack(spacing: 0) {
                    VStack {
                        Text(profile.name)
                            .font(.title2)
                            .bold()
                        HStack {
                            Text("\(profile.rating)")
                                .foregroundStyle(profile.rating == 0 ? .gray : (profile.rating > 0 ? .green : .red))
                            Text("с \(profile.registered)")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Text("\(profile.subscribers_count) подписаны")
                            .foregroundStyle(.gray)
                    }
                    .padding([.leading, .trailing])
                    
                    Picker("Сортировка", selection: $feedSort) {
                        ForEach(feedSorts, id: \.self) { sort in
                            Text(sort.description)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                }
            }
        }
    }
}
