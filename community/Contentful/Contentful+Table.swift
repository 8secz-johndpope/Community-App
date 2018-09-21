//
//  Contentful+Table.swift
//  community
//
//  Created by Jonathan Landon on 8/25/18.
//

import Foundation

extension Contentful {
    
    struct Table: Initializable {
        let id: String
        let title: String
        let postIDs: [String]
        let info: String
        let createdAt: Date
        let updatedAt: Date
        
        var posts: [Contentful.Post] {
            var posts: [Contentful.Post] = []
            
            let storedPosts = Contentful.LocalStorage.posts
            
            for id in postIDs {
                if let post = storedPosts.first(where: { $0.id == id }) {
                    posts.append(post)
                }
            }
            
            return posts
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title")
                else { return nil }
            
            self.id        = id
            self.title     = title
            self.postIDs   = json.dictionary(forKey: "fields").array(forKey: "posts").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.info      = json.dictionary(forKeys: "fields").string(forKey: "description") ?? ""
            self.createdAt = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }
    
}
