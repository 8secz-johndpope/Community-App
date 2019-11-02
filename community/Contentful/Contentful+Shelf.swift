//
//  Contentful+Shelf.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import UIKit
import Diakoneo

extension Contentful {
    
    struct Shelf {
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
        
        init?(entry: Contentful.Entry) {
            guard
                let name = entry.fields.string(forKey: "name")
            else { return nil }
            
            self.id        = entry.id
            self.name      = name
            self.postIDs   = entry.fields.array(forKey: "posts").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.shelfIDs  = entry.fields.array(forKey: "shelves").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.icon      = entry.fields.string(forKey: "icon").flatMap(Icon.init(string:))
            self.createdAt = entry.createdAt
            self.updatedAt = entry.updatedAt
        }
        
        func show(in viewController: UIViewController? = .current, from source: Analytics.ShelfSource) {
            let controller = ShelfViewController(shelf: self)
            
            if let navController = viewController?.navigationController {
                navController.pushViewController(controller, animated: true)
            }
            else {
                viewController?.present(controller, animated: true)
            }
            
            Analytics.viewed(shelf: self, source: source)
        }
    }

}
