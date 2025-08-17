import SwiftUI

struct OdesliView: View {
    let item: Odesli
    var body: some View {
        VStack {
            if let song = item.entitiesByUniqueId.values.first {
                HStack {
                    AsyncImage(url: song.thumbnailUrl) { img in
                        img
                            .resizable()
                    } placeholder: {
                        Rectangle()
                            .foregroundStyle(.gray)
                    }
                    .cornerRadius(10)
                    .frame(width: 100, height: 100)
                    VStack {
                        Text(song.title)
                            .font(.caption)
                        Text(song.artistName)
                            .font(.caption2)
                    }
                    .bold()
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(item.linksByPlatform), id: \.key) { linkData in
                        Link(destination: linkData.value.url) {
                            Text(linkData.key)
                        }
                    }
                }
            }
            .frame(height: 30)
        }
    }
}
