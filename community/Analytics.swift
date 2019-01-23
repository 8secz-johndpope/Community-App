//
//  Analytics.swift
//  community
//
//  Created by Jonathan Landon on 1/22/19.
//

import Foundation
import FirebaseAnalytics

enum Analytics {
    
    enum Event: String {
        case app_opened
        case viewed_question
        case viewed_table_post
        case viewed_intro_video
        case viewed_pantry_shelf
        case viewed_pantry_post
        case searched
        case viewed_search_shelf
        case viewed_search_post
    }
    
    static func log(_ event: Event, with parameters: [String : Any] = [:]) {
        FirebaseAnalytics.Analytics.logEvent(event.rawValue, parameters: parameters)
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
    
    static func viewed(tablePost post: Contentful.Post) {
        log(.viewed_table_post, with: [
            "id" : post.id,
            "title" : post.title,
            "type" : post.type.title
        ])
    }
    
    static func viewedIntroView() {
        log(.viewed_intro_video)
    }
    
    static func viewed(pantryShelf shelf: Contentful.Shelf) {
        log(.viewed_pantry_shelf, with: [
            "id" : shelf.id,
            "title" : shelf.name
        ])
    }
    
    static func viewed(pantryPost post: Contentful.Post) {
        log(.viewed_pantry_post, with: [
            "id" : post.id,
            "title" : post.title,
            "type" : post.type.title
        ])
    }
    
    static func searched(query: String, shelfCount: Int, postCount: Int) {
        log(.searched, with: [
            "query" : query,
            "shelf_count" : shelfCount,
            "post_count" : postCount
        ])
    }
    
    static func viewed(searchShelf shelf: Contentful.Shelf) {
        log(.viewed_search_shelf, with: [
            "id" : shelf.id,
            "title" : shelf.name
        ])
    }
    
    static func viewed(searchPost post: Contentful.Post) {
        log(.viewed_search_post, with: [
            "id" : post.id,
            "title" : post.title,
            "type" : post.type.title
        ])
    }
}
