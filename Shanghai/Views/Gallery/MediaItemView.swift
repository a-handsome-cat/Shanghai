import SwiftUI
import AVKit

struct MediaItemView: View {
    let item: ImageData
    @ObservedObject var viewModel: GalleryViewModel
    let fullscreen: Bool
    
    @State var muted = false
    
    var body: some View {
            switch item.url.pathExtension {
            case "webp", "jpg":
                if let dataURL = item.localDataURL, let uiImage = UIImage(contentsOfFile: dataURL.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    VStack {
                        Image(systemName: "photo.badge.exclamationmark")
                        Text("Не загрузилось(")
                    }
                }
            case "mp4", "mov":
                if let dataURL = item.localDataURL {
                    if let player = viewModel.player?.0 {
                        VideoPlayerView(player: player, fullscreen: fullscreen)
                            .onDisappear {
                                if !fullscreen {
                                    player.pause()
                                    viewModel.player = nil
                                }
                            }
                    } else {
                        ProgressView()
                            .frame(width: 200, height: 20)
                            .onAppear {
                                let player = AVQueuePlayer(url: dataURL)
                                player.isMuted = !AudioObserver.shared.soundEnabled
                                let looper = AVPlayerLooper(player: player, templateItem: player.currentItem!)
                                
                                viewModel.player = (player, looper)
                            }
                    }
                } else {
                    Image(systemName: "video.slash.fill")
                    Text("Не загрузилось(")
                }
            default:
                Text("This media is not supported")
            }
    }
}
