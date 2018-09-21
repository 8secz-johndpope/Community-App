//
//  Contentful+Entry.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Contentful {
    
    enum Entry {
        case author(Contentful.Author)
        case externalPost(Contentful.ExternalPost)
        case pantry(Contentful.Pantry)
        case table(Contentful.Table)
        case shelf(Contentful.Shelf)
        case textPost(Contentful.TextPost)
    }
    
}

extension Contentful.Entry: Initializable {
    
    init?(json: [String : Any]) {
        guard let type: Contentful.API.ContentType = json.dictionary(forKeys: "sys", "contentType", "sys").enum(forKey: "id") else { return nil }
        
        switch type {
        case .author:
            if let author = Contentful.Author(json: json) {
                self = .author(author)
            }
            else {
                return nil
            }
        case .externalPost:
            if let externalPost = Contentful.ExternalPost(json: json) {
                self = .externalPost(externalPost)
            }
            else {
                return nil
            }
        case .pantry:
            if let pantry = Contentful.Pantry(json: json) {
                self = .pantry(pantry)
            }
            else {
                return nil
            }
        case .table:
            if let table = Contentful.Table(json: json) {
                self = .table(table)
            }
            else {
                return nil
            }
        case .shelf:
            if let shelf = Contentful.Shelf(json: json) {
                self = .shelf(shelf)
            }
            else {
                return nil
            }
        case .textPost:
            if let textPost = Contentful.TextPost(json: json) {
                self = .textPost(textPost)
            }
            else {
                return nil
            }
        }
    }
    
}

extension Contentful.Entry {
    
    var createdAt: Date {
        switch self {
        case .author(let author):             return author.createdAt
        case .externalPost(let externalPost): return externalPost.createdAt
        case .pantry(let pantry):             return pantry.createdAt
        case .table(let table):               return table.createdAt
        case .textPost(let textPost):         return textPost.createdAt
        case .shelf(let shelf):               return shelf.createdAt
        }
    }
    
    var updatedAt: Date {
        switch self {
        case .author(let author):             return author.updatedAt
        case .externalPost(let externalPost): return externalPost.updatedAt
        case .pantry(let pantry):             return pantry.updatedAt
        case .table(let table):               return table.updatedAt
        case .textPost(let textPost):         return textPost.updatedAt
        case .shelf(let shelf):               return shelf.updatedAt
        }
    }
    
    var title: String {
        switch self {
        case .author(let author):             return author.name
        case .externalPost(let externalPost): return externalPost.title
        case .pantry(let pantry):             return pantry.title
        case .table(let table):               return table.title
        case .textPost(let textPost):         return textPost.title
        case .shelf(let shelf):               return shelf.name
        }
    }
    
}
