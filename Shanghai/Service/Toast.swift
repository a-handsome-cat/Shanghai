import SwiftUI

struct ToastView: ViewModifier {
    @Binding var showToast: Bool
    let text: String
    
    func body(content: Content) -> some View {
        content
            .overlay {
                VStack {
                    Spacer()
                    if showToast {
                        Text(text)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                            .offset(y: -20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        showToast = false
                                }
                            }
                    }
                }
                .animation(.easeInOut, value: showToast)
            }
    }
}

extension View {
    func toast(showToast: Binding<Bool>, text: String) -> some View {
        modifier(ToastView(showToast: showToast, text: text))
    }
}
