//
//  MediaProgressManager.swift
//  community
//
//  Created by Jonathan Landon on 1/22/20.
//

import Foundation
import Diakoneo
import Alexandria

enum MediaProgressManager {
    
    private static var path: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents + "media_progress.json"
    }
    
    private static var storage: Set<Media> = []
    private static var completionThreshold: Double = 0.8
    
    static func initialize() {
        guard let data = try? Data(contentsOf: path) else { return }
        
        let json = JSONSerialization.dictionary(from: data)
        let media: [MediaProgressManager.Media] = json.array(forKey: "media")
        
        storage = Set(media)
    }
    
    // ID + Type
    
    static func isComplete(id: String, type: MediaType) -> Bool {
        let progress = MediaProgressManager.progress(forID: id, type: type) ?? 0
        return progress > MediaProgressManager.completionThreshold
    }
    
    static func add(id: String, type: MediaType, timestamp: TimeInterval, progress: Double) {
        storage.remove(Media(id: id, type: type, timestamp: 0, progress: 0))
        storage.insert(Media(id: id, type: type, timestamp: timestamp, progress: progress))
        save()
    }
    
    static func remove(id: String, type: MediaType) {
        storage.remove(Media(id: id, type: type, timestamp: 0, progress: 0))
        save()
    }
    
    static func timestamp(forID id: String, type: MediaType) -> TimeInterval? {
        if let time = storage.first(where: { $0.id == id && $0.type == type })?.timestamp {
            return (time - 5).limited(0, time)
        }
        else {
            return nil
        }
    }
    
    static func progress(forID id: String, type: MediaType) -> Double? {
        storage.first(where: { $0.id == id && $0.type == type })?.progress
    }
    
    // Contentful
    
    static func isComplete(post: Contentful.Post) -> Bool {
        isComplete(id: post.id, type: .contentfulPost)
    }
    
    static func add(post: Contentful.Post, timestamp: TimeInterval, progress: Double) {
        add(id: post.id, type: .contentfulPost, timestamp: timestamp, progress: progress)
    }
    
    static func remove(post: Contentful.Post) {
        remove(id: post.id, type: .contentfulPost)
    }
    
    static func timestamp(forPost post: Contentful.Post) -> TimeInterval? {
        timestamp(forID: post.id, type: .contentfulPost)
    }
    
    static func progress(forPost post: Contentful.Post) -> Double? {
        progress(forID: post.id, type: .contentfulPost)
    }
    
    // Watermark
    
    static func isComplete(message: Watermark.Message) -> Bool {
        isComplete(id: message.id.string, type: .watermarkMessage)
    }
    
    static func add(message: Watermark.Message, timestamp: TimeInterval, progress: Double) {
        add(id: message.id.string, type: .watermarkMessage, timestamp: timestamp, progress: progress)
    }
    
    static func remove(message: Watermark.Message) {
        remove(id: message.id.string, type: .watermarkMessage)
    }
    
    static func timestamp(forMessage message: Watermark.Message) -> TimeInterval? {
        timestamp(forID: message.id.string, type: .watermarkMessage)
    }
    
    static func progress(forMessage message: Watermark.Message) -> Double? {
        progress(forID: message.id.string, type: .watermarkMessage)
    }
    
}

extension MediaProgressManager {
    
    private static func save() {
        do {
            let dictionary = ["media" : storage.map { $0.json }]
            if JSONSerialization.isValidJSONObject(dictionary) {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
                try data.write(to: path)
                
                Notifier.onMediaProgressSaved.fire(())
            }
            else {
                print("Invalid JSON: \(dictionary)")
            }
        }
        catch {
            print("Error saving progress: \(error.localizedDescription)")
        }
    }
    
}

extension MediaProgressManager {
    
    enum MediaType: String {
        case watermarkMessage
        case contentfulPost
    }
    
    struct Media: Initializable, Hashable {
        let id: String
        let type: MediaType
        let timestamp: TimeInterval
        let progress: Double
        
        init(id: String, type: MediaType, timestamp: TimeInterval, progress: TimeInterval) {
            self.id        = id
            self.type      = type
            self.timestamp = timestamp.limited(0, 18_000)
            self.progress  = progress.limited(0, 1)
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.string(forKey: "id"),
                let type: MediaType = json.enum(forKey: "type"),
                let timestamp = json.double(forKey: "timestamp"),
                let progress = json.double(forKey: "progress")
            else { return nil }
            
            self.id        = id
            self.type      = type
            self.timestamp = timestamp.limited(0, 18_000)
            self.progress  = progress.limited(0, 1)
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(type)
        }
        
        static func ==(lhs: Media, rhs: Media) -> Bool {
            return lhs.id == rhs.id && lhs.type == rhs.type
        }
        
        var json: [String : Any] {
            return [
                "id" : id,
                "type" : type.rawValue,
                "timestamp" : Int(timestamp.limited(0, 18_000)),
                "progress" : progress.limited(0, 1)
            ]
        }
    }
    
}
