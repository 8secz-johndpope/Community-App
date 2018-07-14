//
//  Contentful+Shelf.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

extension Contentful {
    
    struct Shelf: Initializable {
        let id: String
        let name: String
        let postIDs: [String]
        let createdAt: Date
        let updatedAt: Date
        
        var posts: [Contentful.Post] {
            return (
                Contentful.LocalStorage.externalPosts.filter { postIDs.contains($0.id) }.map(Contentful.Post.external) +
                Contentful.LocalStorage.textPosts.filter { postIDs.contains($0.id) }.map(Contentful.Post.text)
            ).sorted(by: { $0.updatedAt < $1.updatedAt })
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let name = json.dictionary(forKey: "fields").string(forKey: "name")
            else { return nil }
            
            self.id        = id
            self.name      = name
            self.postIDs   = json.dictionary(forKey: "fields").array(forKey: "posts").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.createdAt = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }

}
