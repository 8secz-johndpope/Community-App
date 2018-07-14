//
//  Contentful+TextPost.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

extension Contentful {
    
    struct TextPost: Initializable {
        let id: String
        let title: String
        let content: String
        let publishDate: Date
        let authorID: String
        let postImageAssetID: String
        let isInTable: Bool
        let createdAt: Date
        let updatedAt: Date
        
        var author: Contentful.Author? {
            return Contentful.LocalStorage.authors.first(where: { $0.id == authorID })
        }
        
        var image: Contentful.Asset? {
            return Contentful.LocalStorage.assets.first(where: { $0.id == postImageAssetID })
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title"),
                let content = json.dictionary(forKey: "fields").string(forKey: "content"),
                let publishDate = json.dictionary(forKey: "fields").date(forKey: "publishDate", formatter: .yearMonthDay),
                let authorID = json.dictionary(forKeys: "fields", "author", "sys").string(forKey: "id"),
                let isInTable = json.dictionary(forKey: "fields").bool(forKey: "tableQueue")
            else { return nil }
            
            self.id               = id
            self.title            = title
            self.content          = content
            self.publishDate      = publishDate
            self.authorID         = authorID
            self.postImageAssetID = json.dictionary(forKeys: "fields", "postImage", "sys").string(forKey: "id") ?? ""
            self.isInTable        = isInTable
            self.createdAt        = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt        = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }

}
