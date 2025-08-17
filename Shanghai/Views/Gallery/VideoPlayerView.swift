import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State var player: AVPlayer
    let fullscreen: Bool
    
    var body: some View {
        GeometryReader { geo in
            VideoPlayer(player: player)
                .disabled(true)
                .overlay {
                    HStack {}
                      .frame(maxWidth: .infinity, maxHeight: .infinity)
                      .contentShape(Rectangle())
                    VideoPlayerOverlayView(player: player)
                        .padding()
                }
                .onAppear {
                    if UIScreen.main.bounds.contains(geo.frame(in: .global)) {
                        player.play()
                    }
                }
                .onChange(of: geo.frame(in: .global)) { oldValue, newValue in
                    let screenBounds = UIScreen.main.bounds
                    
                    let wasVisible = screenBounds.contains(oldValue)
                    let isNowVisible = screenBounds.contains(newValue)
                    
                    if !wasVisible && isNowVisible {
                        player.play()
                    } else if wasVisible && !isNowVisible && !fullscreen {
                        player.pause()
                    }
                }
        }
    }
}
