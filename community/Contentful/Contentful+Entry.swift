//
//  Contentful+Entry.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation
import Diakoneo

extension Contentful.API {
    
    enum ContentType: String {
        case author
        case externalPost
        case pantry
        case table
        case textPost = "post"
        case shelf
        case question
        case communityQuestions
        case leadershipLessons
        case search
        case intro
    }
    
}

extension Contentful.Entry {
    
    enum Community {
        case author(Contentful.Author)
        case externalPost(Contentful.ExternalPost)
        case pantry(Contentful.Pantry)
        case table(Contentful.Table)
        case shelf(Contentful.Shelf)
        case textPost(Contentful.TextPost)
        case question(Contentful.Question)
        case communityQuestions(Contentful.CommunityQuestions)
        case leadershipLessons(Contentful.LeadershipLessons)
        case search(Contentful.Search)
        case intro(Contentful.Intro)
    }
    
}

extension Contentful.Entry.Community {
    
    init?(entry: Contentful.Entry) {
        guard let type = Contentful.API.ContentType(rawValue: entry.contentType) else { return nil }
        
        switch type {
        case .author:
            if let author = Contentful.Author(entry: entry) {
                self = .author(author)
            }
            else {
                return nil
            }
        case .externalPost:
            if let externalPost = Contentful.ExternalPost(entry: entry) {
                self = .externalPost(externalPost)
            }
            else {
                return nil
            }
        case .pantry:
            if let pantry = Contentful.Pantry(entry: entry) {
                self = .pantry(pantry)
            }
            else {
                return nil
            }
        case .table:
            if let table = Contentful.Table(entry: entry) {
                self = .table(table)
            }
            else {
                return nil
            }
        case .shelf:
            if let shelf = Contentful.Shelf(entry: entry) {
                self = .shelf(shelf)
            }
            else {
                return nil
            }
        case .textPost:
            if let textPost = Contentful.TextPost(entry: entry) {
                self = .textPost(textPost)
            }
            else {
                return nil
            }
        case .question:
            if let question = Contentful.Question(entry: entry) {
                self = .question(question)
            }
            else {
                return nil
            }
        case .communityQuestions:
            if let communityQuestions = Contentful.CommunityQuestions(entry: entry) {
                self = .communityQuestions(communityQuestions)
            }
            else {
                return nil
            }
        case .leadershipLessons:
            if let leadershipLessons = Contentful.LeadershipLessons(entry: entry) {
                self = .leadershipLessons(leadershipLessons)
            }
            else {
                return nil
            }
        case .search:
            if let search = Contentful.Search(entry: entry) {
                self = .search(search)
            }
            else {
                return nil
            }
        case .intro:
            if let intro = Contentful.Intro(entry: entry) {
                self = .intro(intro)
            }
            else {
                return nil
            }
        }
    }
    
}

extension Contentful.Entry.Community {
    
    var createdAt: Date {
        switch self {
        case .author(let author):                       return author.createdAt
        case .externalPost(let externalPost):           return externalPost.createdAt
        case .pantry(let pantry):                       return pantry.createdAt
        case .table(let table):                         return table.createdAt
        case .textPost(let textPost):                   return textPost.createdAt
        case .shelf(let shelf):                         return shelf.createdAt
        case .question(let question):                   return question.createdAt
        case .communityQuestions(let questions):        return questions.createdAt
        case .leadershipLessons(let leadershipLessons): return leadershipLessons.createdAt
        case .search(let search):                       return search.createdAt
        case .intro(let intro):                         return intro.createdAt
        }
    }
    
    var updatedAt: Date {
        switch self {
        case .author(let author):                       return author.updatedAt
        case .externalPost(let externalPost):           return externalPost.updatedAt
        case .pantry(let pantry):                       return pantry.updatedAt
        case .table(let table):                         return table.updatedAt
        case .textPost(let textPost):                   return textPost.updatedAt
        case .shelf(let shelf):                         return shelf.updatedAt
        case .question(let question):                   return question.updatedAt
        case .communityQuestions(let questions):        return questions.updatedAt
        case .leadershipLessons(let leadershipLessons): return leadershipLessons.updatedAt
        case .search(let search):                       return search.updatedAt
        case .intro(let intro):                         return intro.updatedAt
        }
    }
    
    var title: String {
        switch self {
        case .author(let author):                       return author.name
        case .externalPost(let externalPost):           return externalPost.title
        case .pantry(let pantry):                       return pantry.title
        case .table(let table):                         return table.title
        case .textPost(let textPost):                   return textPost.title
        case .shelf(let shelf):                         return shelf.name
        case .question(let question):                   return question.question
        case .communityQuestions(let questions):        return questions.title
        case .leadershipLessons(let leadershipLessons): return leadershipLessons.title
        case .search(let search):                       return search.title
        case .intro(let intro):                         return intro.title
        }
    }
    
}
