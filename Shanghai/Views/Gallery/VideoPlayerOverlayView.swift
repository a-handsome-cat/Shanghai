import SwiftUI
import AVKit

struct VideoPlayerOverlayView: View {
    @StateObject var audioObserver = AudioObserver.shared
    var player: AVPlayer
    var body: some View {
        VStack {
            HStack {
                
            }
            Spacer()
            HStack {
                Spacer()
                Circle()
                    .foregroundStyle(Color.black.opacity(0.7))
                    .frame(width: 30)
                    .overlay {
                        Image(systemName: audioObserver.soundEnabled ? "speaker.fill" : "speaker.slash.fill")
                    }
                    .highPriorityGesture(TapGesture().onEnded({ _ in
                        player.isMuted = audioObserver.soundEnabled
                        audioObserver.soundEnabled ? audioObserver.setAmbientAudio() : audioObserver.setPlaybackAudio()
                    }))
            }
            .font(.system(size: 18))
            .foregroundColor(.white)
        }
    }
}
