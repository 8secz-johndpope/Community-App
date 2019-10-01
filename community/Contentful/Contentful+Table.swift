//
//  Contentful+Table.swift
//  community
//
//  Created by Jonathan Landon on 8/25/18.
//

import Diakoneo

extension Contentful {
    
    struct Table {
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
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title")
            else { return nil }
            
            self.id        = entry.id
            self.title     = title
            self.postIDs   = entry.fields.array(forKey: "posts").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.info      = entry.fields.string(forKey: "description") ?? ""
            self.createdAt = entry.createdAt
            self.updatedAt = entry.updatedAt
        }
    }
    
}
