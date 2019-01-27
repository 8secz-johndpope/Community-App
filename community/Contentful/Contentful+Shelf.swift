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
        let shelfIDs: [String]
        let createdAt: Date
        let updatedAt: Date
        let icon: Icon?
        
        var posts: [Contentful.Post] {
            var posts: [Contentful.Post] = []
            
            for id in postIDs {
                if let post = Contentful.LocalStorage.posts.first(where: { $0.id == id }) {
                    posts.append(post)
                }
            }
            
            return posts
        }
        
        var shelves: [Contentful.Shelf] {
            var shelves: [Contentful.Shelf] = []
            
            for id in shelfIDs {
                if let shelf = Contentful.LocalStorage.shelves.first(where: { $0.id == id }) {
                    shelves.append(shelf)
                }
            }
            
            return shelves
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let name = json.dictionary(forKey: "fields").string(forKey: "name")
            else { return nil }
            
            self.id        = id
            self.name      = name
            self.postIDs   = json.dictionary(forKey: "fields").array(forKey: "posts").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.shelfIDs  = json.dictionary(forKey: "fields").array(forKey: "shelves").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.icon      = json.dictionary(forKey: "fields").string(forKey: "icon").flatMap(Icon.init(string:))
            self.createdAt = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }

}
