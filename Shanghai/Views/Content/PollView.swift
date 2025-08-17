import SwiftUI

struct PollView: View {
    @State var poll: Poll?
    let id: Int
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).cornerRadius(10)
            VStack(alignment: .leading, spacing: 8) {
                if let header = poll?.header, !header.isEmpty {
                    Text(header)
                        .font(.title3)
                        .bold()
                }
                ForEach(poll?.variants ?? [PollVariant]()) { variant in
                    HStack {
                        Button {
                            vote(variant: variant.id)
                        } label: {
                            if let poll = poll, poll.voted.isEmpty {
                                Text("〇")
                                    .bold()
                            } else {
                                if let poll = poll, poll.voted.contains(where: { $0 == variant.id }) {
                                    Text("✔")
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundStyle(Color.black)
                        Text(variant.label)
                        Spacer()
                        if let voted = poll?.voted, !voted.isEmpty, let count = variant.votes_count {
                            Text("\(count)")
                        }
                    }
                }
            }
            .padding()
        }
        .task {
            do {
                poll = try await Web.shared.fetchPoll(id: id)
            } catch {
                
            }
        }
    }
    
    func vote(variant id: Int) {
        Task {
            poll?.voted.append(id)
            self.poll = try await Web.shared.votePoll(pollId: poll!.id, variantId: id)
        }
    }
}
