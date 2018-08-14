//
//  Contentful+Post.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Contentful {
    
    enum Post {
        case text(Contentful.TextPost)
        case external(Contentful.ExternalPost)
    }
    
}

extension Contentful.Post {
    
    var image: URL? {
        switch self {
        case .text(let post):     return post.image?.url
        case .external(let post): return post.image?.url
        }
    }
    
    var publishDate: Date {
        switch self {
        case .text(let post):     return post.publishDate
        case .external(let post): return post.publishDate
        }
    }
    
    var createdAt: Date {
        switch self {
        case .text(let post):     return post.createdAt
        case .external(let post): return post.createdAt
        }
    }
    
    var updatedAt: Date {
        switch self {
        case .text(let post):     return post.updatedAt
        case .external(let post): return post.updatedAt
        }
    }
    
    var title: String {
        switch self {
        case .text(let post):     return post.title
        case .external(let post): return post.title
        }
    }
    
    var isInTable: Bool {
        switch self {
        case .text(let post):     return post.isInTable
        case .external(let post): return post.isInTable
        }
    }
    
}
