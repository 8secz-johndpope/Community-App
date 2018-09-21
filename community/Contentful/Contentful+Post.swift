//
//  Contentful+Post.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit

extension Contentful {
    
    enum Post {
        case text(Contentful.TextPost)
        case external(Contentful.ExternalPost)
    }
    
    enum PostType: String {
        case sermonGuide = "sermon_guide"
        case sermon
        case rtrq
        case website
        case post
        case file
        
        var title: String {
            switch self {
            case .sermonGuide: return "SERMON GUIDE"
            case .sermon:      return "MESSAGE"
            case .rtrq:        return "REAL TRUTH. REAL QUICK."
            case .website:     return "WEBSITE"
            case .post:        return "POST"
            case .file:        return "FILE"
            }
        }
        
        var backgroundColor: UIColor {
            switch self {
            case .sermonGuide: return .dark
            case .sermon:      return .orange
            case .rtrq:        return #colorLiteral(red: 0.1137254902, green: 0.6823529412, blue: 0.9254901961, alpha: 1)
            case .website:     return #colorLiteral(red: 0.3098039216, green: 0.537254902, blue: 0.8509803922, alpha: 1)
            case .post:        return .grayBlue
            case .file:        return .gray
            }
        }
    }
    
}

extension Contentful.Post {
    
    var type: Contentful.PostType {
        switch self {
        case .text(let post):     return post.type
        case .external(let post): return post.type
        }
    }
    
    var id: String {
        switch self {
        case .text(let post):     return post.id
        case .external(let post): return post.id
        }
    }
    
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
