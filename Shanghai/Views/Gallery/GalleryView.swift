import SwiftUI

struct GalleryView: View {
    @StateObject var viewModel: GalleryViewModel
    @State var images: Gallery
    
    @State var fullscreen = false
    @State var selectedItem = 0
    
    init(images: Gallery) {
        self.images = images
        self._viewModel = StateObject(wrappedValue: GalleryViewModel(items: images.images))
    }
    
    var body: some View {
        tabView()
        .background {
            if images.height == nil {
                GeometryReader { geo in
                    Color.gray
                        .opacity(0.3)
                        .onAppear {
                            images.height = getGalleryHeight(items: images.images, widthAvailable: geo.size.width)
                        }
                }
            }
        }
        .onTapGesture {
            fullscreen = true
        }
        .overlay {
            if images.images.count > 1 {
                VStack {
                    HStack {
                        Spacer()
                        Text("\(selectedItem + 1)/\(images.images.count)")
                            .foregroundStyle(.white)
                            .padding(5)
                            .background {
                                Rectangle()
                                    .opacity(0.5)
                                    .cornerRadius(4)
                            }
                    }
                    Spacer()
                }
                .padding(4)
            }
        }
        .cornerRadius(10)
        .frame(height: images.height)
        .sheet(isPresented: $fullscreen) {
            tabView()
                .background(.black)
        }
    }
    
    func tabView() -> some View {
        TabView(selection: $selectedItem) {
            ForEach(images.images.indices, id: \.self) { index in
                MediaItemView(item: images.images[index], viewModel: viewModel, fullscreen: fullscreen)
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
    }
    
    func getGalleryHeight(items: [ImageData], widthAvailable: CGFloat) -> CGFloat {
        var maxH: CGFloat = 0
        
        for item in items {
            if let width = item.width, let height = item.height {
                let ratio = widthAvailable / width
                maxH = max(maxH, height * ratio)
            }
        }
        
        return min(maxH, 500)
    }
}
