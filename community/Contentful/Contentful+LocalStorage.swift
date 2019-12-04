//
//  Contentful+LocalStorage.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Diakoneo

extension Contentful.LocalStorage {
    
    static var authors: [Contentful.Author]             = []
    static var externalPosts: [Contentful.ExternalPost] = []
    static var textPosts: [Contentful.TextPost]         = []
    static var shelves: [Contentful.Shelf]              = []
    static var questions: [Contentful.Question]         = []
    
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
    
    static var communityQuestions: Contentful.CommunityQuestions? {
        didSet {
            Notifier.onCommunityQuestionsChanged.fire(())
        }
    }
    
    static var featuredSection: Contentful.FeaturedSection? {
        didSet {
            Notifier.onFeaturedSectionChanged.fire(())
        }
    }
    
    static var search: Contentful.Search? {
        didSet {
            Notifier.onSearchChanged.fire(())
        }
    }
    
    static var intro: Contentful.Intro? {
        didSet {
            Notifier.onIntroChanged.fire(())
        }
    }
    
}
