//
//  Contentful+TextPost.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

enum MediaType {
    case audio
    case video
}

enum Media {
    case message(Int)
    case raw(URL)
    case youtube(String)
    
    struct Data {
        let url: URL
        let mediaType: MediaType
        let message: Watermark.Message?
    }
    
    enum Error: Swift.Error {
        case missingURL
        case unknown
    }
    
    func fetch(completion: @escaping (Result<(Media.Data), Error>) -> Void) {
        switch self {
        case .message(let id):
            Watermark.API.Messages.fetch(id: id) { result in
                DispatchQueue.main.async {
                    guard let message = result.value else { return completion(.error(.missingURL)) }
                    
                    switch message.mediaAsset {
                    case .audio(let asset): completion(.value(Data(url: asset.url, mediaType: .audio, message: message)))
                    case .video(let asset): completion(.value(Data(url: asset.url, mediaType: .video, message: message)))
                    }
                }
            }
        case .raw(let url):
            if url.isAudio {
                completion(.value(Data(url: url, mediaType: .audio, message: nil)))
            }
            else if url.isVideo {
                completion(.value(Data(url: url, mediaType: .video, message: nil)))
            }
        case .youtube(let id):
            YouTube.fetchVideo(id: id) { url in
                DispatchQueue.main.async {
                    guard let url = url else { return completion(.error(.missingURL)) }
                    completion(.value(Data(url: url, mediaType: .video, message: nil)))
                }
            }
        }
    }
}

extension Contentful {
    
    struct TextPost: Initializable {
        let id: String
        let title: String
        let content: String
        let publishDate: Date
        let authorID: String
        let postImageAssetID: String
        let mediaURL: URL?
        let isInTable: Bool
        let createdAt: Date
        let updatedAt: Date
        let type: PostType
        let media: Media?
        
        var hasMedia: Bool {
            return mediaURL != nil
        }
        
        var author: Contentful.Author? {
            return Contentful.LocalStorage.authors.first(where: { $0.id == authorID })
        }
        
        var image: Contentful.Asset? {
            return Contentful.LocalStorage.assets.first(where: { $0.id == postImageAssetID })
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title"),
                let content = json.dictionary(forKey: "fields").string(forKey: "content"),
                let publishDate = json.dictionary(forKey: "fields").date(forKey: "publishDate", formatter: .yearMonthDay),
                let isInTable = json.dictionary(forKey: "fields").bool(forKey: "tableQueue"),
                publishDate < Date()
            else { return nil }
            
            self.id               = id
            self.title            = title
            self.content          = content
            self.publishDate      = publishDate
            self.authorID         = json.dictionary(forKeys: "fields", "author", "sys").string(forKey: "id") ?? ""
            self.postImageAssetID = json.dictionary(forKeys: "fields", "postImage", "sys").string(forKey: "id") ?? ""
            self.mediaURL         = json.dictionary(forKey: "fields").url(forKey: "mediaUrl")
            self.isInTable        = isInTable
            self.createdAt        = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt        = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
            self.type             = json.dictionary(forKey: "fields").enum(forKey: "type") ?? .post
            
            if let mediaURL = self.mediaURL {
                switch mediaURL.host {
                case "www.watermark.org":
                    let pathComponents = mediaURL.path.components(separatedBy: "/").filter { !$0.isEmpty }
                    
                    if let id = pathComponents.at(1).flatMap(Int.init), pathComponents.at(0) == "message" {
                        self.media = .message(id)
                    }
                    else {
                        self.media = nil
                    }
                case "www.youtube.com":
                    if let id = mediaURL.components?.queryItems?.first(where: { $0.name == "v" })?.value {
                        self.media = .youtube(id)
                    }
                    else {
                        self.media = nil
                    }
                default:
                    self.media = .raw(mediaURL)
                }
            }
            else {
                self.media = nil
            }
        }
    }

}
