//
//  Analytics.swift
//  community
//
//  Created by Jonathan Landon on 1/22/19.
//

import Foundation
import Diakoneo
import FirebaseAnalytics

enum Analytics {
    
    enum Event: String {
        case app_opened
        case viewed_question
        case viewed_intro_video
        case searched
        case viewed_post
        case viewed_shelf
    }
    
    enum PostSource: String {
        case table
        case pantry
        case search
        case deepLink
    }
    
    enum ShelfSource: String {
        case pantry
        case search
        case deepLink
    }
    
    static func log(_ event: Event, with parameters: [String : Any] = [:]) {
        #if DEBUG
        print("Logging event: \(event.rawValue), parameters: \(parameters)")
        #else
        FirebaseAnalytics.Analytics.logEvent(event.rawValue, parameters: parameters)
        #endif
    }
    
}

extension Analytics {
    
    static func appOpened() {
        log(.app_opened)
    }
    
    static func viewed(question: Contentful.Question) {
        log(.viewed_question, with: [
            "id" : question.id,
            "question" : question.question
        ])
    }
    
    static func viewed(post: Contentful.Post, source: PostSource) {
        log(.viewed_post, with: [
            "id" : post.id,
            "title" : post.title,
            "type" : post.type.title,
            "source" : source.rawValue.capitalized
        ])
    }
    
    static func viewed(shelf: Contentful.Shelf, source: ShelfSource) {
        log(.viewed_shelf, with: [
            "id" : shelf.id,
            "title" : shelf.name,
            "source" : source.rawValue.capitalized
        ])
    }
    
    static func viewedIntroView() {
        log(.viewed_intro_video)
    }
    
    static func searched(query: String, shelfCount: Int, postCount: Int) {
        log(.searched, with: [
            "query" : query,
            "shelf_count" : shelfCount,
            "post_count" : postCount
        ])
    }
}
