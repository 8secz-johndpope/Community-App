//
//  Contentful+Post.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import UIKit
import Diakoneo

extension Contentful {
    
    enum Post {
        case text(Contentful.TextPost)
        case external(Contentful.ExternalPost)
        
        func show(in viewController: UIViewController? = .current, from source: Analytics.PostSource) {
            switch self {
            case .external(let post): DeepLink.url(post.url).handle()
            case .text(let post):     ContentViewController(textPost: post).show(in: viewController)
            }
            Analytics.viewed(post: self, source: source)
        }
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
            case .sermonGuide: return "Sermon Guide"
            case .sermon:      return "Sermon"
            case .rtrq:        return "Real Truth. Real Quick."
            case .website:     return "Website"
            case .post:        return "Post"
            case .file:        return "File"
            }
        }
        
        var image: UIImage {
            switch self {
            case .sermonGuide: return #imageLiteral(resourceName: "tile4")
            case .sermon:      return #imageLiteral(resourceName: "tile4")
            case .rtrq:        return #imageLiteral(resourceName: "tile2")
            case .website:     return #imageLiteral(resourceName: "tile1")
            case .post:        return #imageLiteral(resourceName: "tile3")
            case .file:        return #imageLiteral(resourceName: "tile3")
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
    
    var authors: [Contentful.Author] {
        switch self {
        case .text(let post): return post.authors
        case .external:       return []
        }
    }
    
}
