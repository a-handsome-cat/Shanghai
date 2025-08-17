import Foundation
import AVKit

extension Web {
    func fetchPostsContent(posts: [Post]) async throws {
        await withTaskGroup(of: Void.self) { group in
            for post in posts {
                for block in post.preview + post.blocks {
                    group.addTask {
                        do {
                            switch block.type {
                            case "ImagePlugin":
                                if let images = block.data.images {
                                    for image in images.images {
                                        try? await self.fetchImageData(image)
                                    }
                                }
                            case "telegram":
                                if let link = block.data.url {
                                    let fetchedPost = try await TelegramParser.shared.fetchTGPost(url: link)
                                    block.data.telegramPost = fetchedPost
                                }
                            case "Odesli":
                                if let url = block.data.url, let apiUrl = URL(string: "https://api.song.link/v1-alpha.1/links?url=\(url)") {
                                    let (data, _) = try await URLSession.shared.data(from: apiUrl)
                                    let models = try? JSONDecoder().decode(Odesli.self, from: data)
                                    block.data.odesliData = models
                                }
                            default:
                                break
                            }
                        } catch {
                            
                        }
                    }
                }
            }
        }
    }
    
    func fetchImageData(_ image: ImageData) async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = String(image.url.lastPathComponent.prefix(64))
        let tempURL = tempDirectory.appendingPathComponent(fileName)
        
        if !FileManager.default.fileExists(atPath: tempURL.path) {
            var request = URLRequest(url: image.url)
            request.timeoutInterval = 5
            let (data, _) = try await URLSession.shared.data(for: request)
            try data.write(to: tempURL)
        }
        image.localDataURL = tempURL
        
        if image.url.pathExtension == "webp" || image.url.pathExtension == "jpg" {
            if image.height == nil || image.width == nil {
                if let uiImage = UIImage(contentsOfFile: tempURL.path) {
                    let size = uiImage.size
                    image.width = size.width * uiImage.scale
                    image.height =  size.height * uiImage.scale
                }
            }
        } else if image.url.pathExtension == "mp4" || image.url.pathExtension == "mov" {
            let asset = AVURLAsset(url: tempURL, options: nil)
            let tracks = try? await asset.loadTracks(withMediaType: .video)
            if let track = tracks?.first {
                let naturalSize = try? await track.load(.naturalSize)
                image.width = naturalSize?.width ?? 500
                image.height = naturalSize?.height ?? 500
            }
        }
    }
}
