import SwiftUI

struct FeedsView: View {
    @State var selectedFeed: FeedSort = .fresh
    let types: [FeedSort] = [.fresh, .feed, .popular]
    
    var body: some View {
        TabView(selection: $selectedFeed) {
            ForEach(types, id: \.self) { sort in
                FeedView(type: .feed(selectedFeed))
                    .id(selectedFeed)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                ForEach(types, id: \.self) { type in
                    Button {
                        selectedFeed = type
                    } label: {
                        Text(type.description)
                            .foregroundStyle(type == selectedFeed ? Color.primary : Color.gray)
                            .bold(type == selectedFeed)
                    }
                }
            }
        }
        .navigationTitle("")
    }
}
