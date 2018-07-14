//
//  Contentful+LocalStorage.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Contentful {
    
    enum LocalStorage {
        static var authors: [Contentful.Author]             = []
        static var assets: [Contentful.Asset]               = []
        static var externalPosts: [Contentful.ExternalPost] = []
        static var textPosts: [Contentful.TextPost]         = []
        static var shelves: [Contentful.Shelf]              = []
        
        static var pantry: Contentful.Pantry? {
            didSet {
                Notifier.onPantryChanged.fire(())
            }
        }
        
        static var tablePosts: [Contentful.Post] {
            let posts = externalPosts.map(Contentful.Post.external) + textPosts.map(Contentful.Post.text)
            return posts.sorted(by: { $0.updatedAt < $1.updatedAt }).filter { $0.isInTable }
        }
    }
    
}
