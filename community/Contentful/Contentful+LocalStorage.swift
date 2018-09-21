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
        
        static var posts: [Contentful.Post] {
            return externalPosts.map(Contentful.Post.external) + textPosts.map(Contentful.Post.text)
        }
        
        static var table: Contentful.Table? {
            didSet {
                Notifier.onTableChanged.fire(())
            }
        }
        
        static var pantry: Contentful.Pantry? {
            didSet {
                Notifier.onPantryChanged.fire(())
            }
        }
        
        static var communityQuestions: Contentful.TextPost? {
            return textPosts.first(where: { $0.title.lowercased() == "community questions" })
        }
    }
    
}
