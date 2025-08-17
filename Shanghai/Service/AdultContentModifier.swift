import SwiftUI

struct AdultContent: ViewModifier {
    @State var show = false
    let ao: Bool
    func body(content: Content) -> some View {
        content
            .overlay {
                if ao && !show {
                    ZStack {
                        Image("adultContent")
                            .resizable()
                            .opacity(0.8)
                        
                        Text("фу пакажи")
                            .foregroundStyle(Color.black)
                            .padding(6)
                            .background(Color.white.cornerRadius(10))
                            .onTapGesture {
                                withAnimation {
                                    self.show = true
                                }
                            }
                    }
                }
            }
    }
}

extension View {
    func adultContent(_ ao: Bool) -> some View {
        modifier(AdultContent(ao: ao))
    }
}
