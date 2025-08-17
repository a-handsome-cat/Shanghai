import SwiftUI

struct CommentEditorPanelView: View {
    @EnvironmentObject var provider: PostViewModel
    @Binding var commentEditorText: String
    var postComment: ((String) -> Void)
    var body: some View {
        VStack(spacing: 10) {
            if let commentToAnswer = provider.commentToAnswer {
                HStack {
                    Text("↑ \(commentToAnswer.author)")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Button {
                        provider.commentToAnswer = nil
                    } label: {
                        Text("Отменить")
                    }
                }
                .font(.caption)
            }
            HStack {
                TextField("Комментарий", text: $commentEditorText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                if !commentEditorText.isEmpty {
                    Button {
                        postComment(commentEditorText)
                        commentEditorText = ""
                    } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.white, .blue)
                                .font(.system(size: 24))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                
            }
            .animation(.default, value: commentEditorText)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
    }
}
