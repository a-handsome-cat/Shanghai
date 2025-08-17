import AVFoundation

class AudioObserver: ObservableObject {
    @Published var soundEnabled = false
    private var volumeObservation: NSKeyValueObservation?
    static let shared = AudioObserver()
    
    init() {
        setAmbientAudio()
        setAudioObserver()
    }
    
    func setAmbientAudio() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        self.soundEnabled = false
    }
    
    func setPlaybackAudio() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
        self.soundEnabled = true
    }
    
    func setAudioObserver() {
        let session = AVAudioSession.sharedInstance()
        volumeObservation = session.observe(\.outputVolume, options: [.new]) { [weak self] _, _ in
            guard let self = self, self.soundEnabled == false else { return }
            DispatchQueue.main.async {
                self.setPlaybackAudio()
                self.soundEnabled = true
            }
        }
    }
    
    deinit {
        volumeObservation?.invalidate()
    }
}
