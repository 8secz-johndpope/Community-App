//
//  Content.swift
//  community
//
//  Created by Jonathan Landon on 10/1/19.
//

import Diakoneo

enum Content {
    
    static func loadAll() {
        
        Contentful.API.loadAllContent { entries, assets in
            
            var authors: [Contentful.Author] = []
            var externalPosts: [Contentful.ExternalPost] = []
            var textPosts: [Contentful.TextPost] = []
            var shelves: [Contentful.Shelf] = []
            var questions: [Contentful.Question] = []
            var pantry: Contentful.Pantry?
            var table: Contentful.Table?
            var communityQuestions: Contentful.CommunityQuestions?
            var search: Contentful.Search?
            var intro: Contentful.Intro?
            
            for entry in entries.compactMap(Contentful.Entry.Community.init(entry:)) {
                switch entry {
                case .author(let author):             authors.append(author)
                case .externalPost(let externalPost): externalPosts.append(externalPost)
                case .pantry(let p):                  pantry = p
                case .table(let t):                   table = t
                case .textPost(let textPost):         textPosts.append(textPost)
                case .shelf(let shelf):               shelves.append(shelf)
                case .question(let question):         questions.append(question)
                case .communityQuestions(let c):      communityQuestions = c
                case .search(let s):                  search = s
                case .intro(let i):                   intro = i
                }
            }
            
            Contentful.LocalStorage.authors            = authors
            Contentful.LocalStorage.assets             = assets
            Contentful.LocalStorage.externalPosts      = externalPosts
            Contentful.LocalStorage.textPosts          = textPosts
            Contentful.LocalStorage.shelves            = shelves
            Contentful.LocalStorage.questions          = questions
            Contentful.LocalStorage.pantry             = pantry
            Contentful.LocalStorage.table              = table
            Contentful.LocalStorage.communityQuestions = communityQuestions
            Contentful.LocalStorage.search             = search
            Contentful.LocalStorage.intro              = intro
            
            Notifier.onContentLoaded.fire(())
            
        }
        
    }
    
    
}
