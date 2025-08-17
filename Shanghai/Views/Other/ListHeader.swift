import SwiftUI

struct ListHeader: View {
    let headerAvatarURL: URL?
    let headerImageURL: URL?
    let headerContent: AnyView?
    
    var body: some View {
        Section(header:
                VStack {
                    if let headerImageURL = headerImageURL {
                        AsyncImage(url: headerImageURL) { img in
                            img
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .foregroundStyle(.gray)
                        }
                        .frame(height: 200)
                        .clipped()
                        
                        if let headerAvatarURL = headerAvatarURL {
                            AsyncImage(url: headerAvatarURL) { img in
                                img
                                    .resizable()
                            } placeholder: {
                                Rectangle()
                                    .foregroundStyle(.gray)
                            }
                            .frame(width: 100, height: 100)
                            .scaledToFill()
                            .clipShape(.circle)
                            .padding(.top, -60)
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .listRowInsets(EdgeInsets())
        ) {
            VStack {
                if headerImageURL == nil, let headerAvatarURL = headerAvatarURL {
                    AsyncImage(url: headerAvatarURL) { img in
                        img
                            .resizable()
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(.gray)
                    }
                    .frame(width: 100, height: 100)
                    .scaledToFill()
                    .clipShape(.circle)
                }
                if let headerContent = headerContent {
                    headerContent
                }
            }
        }
        .listRowSeparator(.hidden)
    }
}
