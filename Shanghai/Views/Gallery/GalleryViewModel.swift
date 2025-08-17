import Foundation
import AVKit

class GalleryViewModel: ObservableObject {
    init(items: [ImageData]) {
        self.id = UUID()
        self.player = nil
    }
    
    let id: UUID
    @Published var player: (AVQueuePlayer, AVPlayerLooper)?
}
