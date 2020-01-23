//
//  Contentful+TextPost.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation
import Diakoneo

enum MediaType {
    case audio
    case video
}

enum Media: Equatable {
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
                    guard let message = result.value else { return completion(.failure(.missingURL)) }
                    
                    switch message.mediaAsset {
                    case .audio(let asset): completion(.success(Data(url: asset.url, mediaType: .audio, message: message)))
                    case .video(let asset): completion(.success(Data(url: asset.url, mediaType: .video, message: message)))
                    }
                }
            }
        case .raw(let url):
            if url.isAudio {
                completion(.success(Data(url: url, mediaType: .audio, message: nil)))
            }
            else if url.isVideo {
                completion(.success(Data(url: url, mediaType: .video, message: nil)))
            }
            else {
                completion(.failure(.missingURL))
            }
        case .youtube(let id):
            YouTube.fetchVideo(id: id) { url in
                DispatchQueue.main.async {
                    guard let url = url else { return completion(.failure(.missingURL)) }
                    completion(.success(Data(url: url, mediaType: .video, message: nil)))
                }
            }
        }
    }
}

extension Contentful {
    
    struct TextPost: Equatable {
        let id: String
        let title: String
        let content: String
        let publishDate: Date
        let authorIDs: [String]
        let postImageAssetID: String
        let mediaURL: URL?
        let createdAt: Date
        let updatedAt: Date
        let type: PostType
        let media: Media?
        
        var hasMedia: Bool {
            return media != nil
        }
        
        var authors: [Contentful.Author] {
            var authors: [Contentful.Author] = []
            
            for id in authorIDs {
                if let author = Contentful.LocalStorage.authors.first(where: { $0.id == id }) {
                    authors.append(author)
                }
            }
            
            return authors
        }
        
        var image: Contentful.Asset? {
            return Contentful.LocalStorage.assets.first(where: { $0.id == postImageAssetID })
        }
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title"),
                let content = entry.fields.string(forKey: "content"),
                let publishDate = entry.fields.date(forKey: "publishDate", formatter: .yearMonthDay),
                publishDate < Date()
            else { return nil }
            
            self.id               = entry.id
            self.title            = title
            self.content          = content
            self.publishDate      = publishDate
            self.authorIDs        = entry.fields.array(forKey: "authors").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.postImageAssetID = entry.fields.dictionary(forKeys: "postImage", "sys").string(forKey: "id") ?? ""
            self.mediaURL         = entry.fields.url(forKey: "mediaUrl") ?? entry.fields.url(forKey: "mediaUrl", encode: true)
            self.createdAt        = entry.createdAt
            self.updatedAt        = entry.updatedAt
            self.type             = entry.fields.enum(forKey: "type") ?? .post
            
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
                    // http://www.youtube.com/watch?v=:id
                    if let id = mediaURL.components?.queryItems?.first(where: { $0.name == "v" })?.value {
                        self.media = .youtube(id)
                    }
                    else {
                        // http://www.youtube.com/v/:id
                        let pathComponents = Array(mediaURL.pathComponents.dropFirst())
                        if pathComponents.count == 2, pathComponents.first == "v" {
                            self.media = .youtube(pathComponents[1])
                        }
                        else {
                            self.media = nil
                        }
                    }
                case "youtu.be":
                    // http://youtu.be/:id
                    self.media = .youtube(mediaURL.lastPathComponent)
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
