//
//  Contentful.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Diakoneo

extension Contentful.API {
    
    enum ExternalPost {
        
        static func search(query: String, completion: @escaping (Result<[Contentful.ExternalPost], Contentful.API.Error>) -> Void) {
            let posts = Contentful.LocalStorage.externalPosts.filter { $0.title.lowercased().contains(query.lowercased()) }
            completion(.success(posts))
        }
        
    }
    
    enum TextPost {
        
        static func search(query: String, completion: @escaping (Result<[Contentful.TextPost], Contentful.API.Error>) -> Void) {
            let posts = Contentful.LocalStorage.textPosts.filter { $0.title.lowercased().contains(query.lowercased()) }
            completion(.success(posts))
        }
        
    }
    
    enum Shelf {
        
        static func search(query: String, completion: @escaping (Result<[Contentful.Shelf], Contentful.API.Error>) -> Void) {
            let shelves = Contentful.LocalStorage.shelves.filter { $0.name.lowercased().contains(query.lowercased()) }
            completion(.success(shelves))
        }
        
    }
    
}
