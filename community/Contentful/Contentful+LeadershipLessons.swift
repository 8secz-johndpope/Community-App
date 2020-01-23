//
//  Contentful+LeadershipLessons.swift
//  community
//
//  Created by Jonathan Landon on 1/21/20.
//

import UIKit
import Diakoneo

extension Contentful {
    
    struct LeadershipLessons {
        let id: String
        let title: String
        let info: String
        let episodeIDs: [String]
        let createdAt: Date
        let updatedAt: Date
        
        var latest: Contentful.Post? {
            episodes.at(0)
        }
        
        var episodes: [Contentful.Post] {
            var episodes: [Contentful.Post] = []
            
            for id in episodeIDs {
                if let episode = Contentful.LocalStorage.posts.first(where: { $0.id == id }) {
                    episodes.append(episode)
                }
            }
            
            return episodes
        }
        
        var recent: [Contentful.Post] {
            Array(episodes.dropFirst())
        }
        
        var unplayed: [Contentful.Post] {
            recent.filter { !MediaProgressManager.isComplete(post: $0) }
        }
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title")
            else { return nil }
            
            self.id         = entry.id
            self.title      = title
            self.info       = entry.fields.string(forKey: "description") ?? ""
            self.episodeIDs = entry.fields.array(forKey: "episodes").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.createdAt  = entry.createdAt
            self.updatedAt  = entry.updatedAt
        }
    }

}
