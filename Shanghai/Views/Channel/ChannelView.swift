import SwiftUI

struct ChannelView: View {
    @State var channelInfo: Channel? = nil
    let id: Int
    @State var feedSort: FeedSort = .fresh
    let feedSorts: [FeedSort] = [.fresh, .old, .best, .worst]
    
    var body: some View {
        if let channelInfo = channelInfo {
            let headerSection = ListHeader(headerAvatarURL: channelInfo.ava, headerImageURL: nil, headerContent: AnyView(header))
            FeedView(type: .channel(id, feedSort), headerSection: headerSection)
                .id(feedSort)
            Spacer()
        } else {
            ProgressView()
                .task {
                    do {
                        self.channelInfo = try await Web.shared.getChannelInfo(id: id)
                    } catch {
                        
                    }
                }
        }
        
    }
    
    var header: some View {
        VStack {
            if let channelInfo = channelInfo {
                VStack {
                    Text(channelInfo.name)
                        .font(.title2)
                        .bold()
                    if let description = channelInfo.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    if let rules = channelInfo.rules {
                        Text("Правила подсайта")
                            .font(.title3)
                        Text(rules)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                .padding()
                
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
