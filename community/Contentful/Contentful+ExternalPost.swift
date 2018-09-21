//
//  Contentful+ExternalPost.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

extension Contentful {
    
    struct ExternalPost: Initializable {
        let id: String
        let title: String
        let publishDate: Date
        let url: URL
        let postImageAssetID: String
        let isInTable: Bool
        let createdAt: Date
        let updatedAt: Date
        let type: PostType
        
        var image: Contentful.Asset? {
            return Contentful.LocalStorage.assets.first(where: { $0.id == postImageAssetID })
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title"),
                let publishDate = json.dictionary(forKey: "fields").date(forKey: "publishDate", formatter: .yearMonthDay),
                let url = json.dictionary(forKey: "fields").url(forKey: "url"),
                let isInTable = json.dictionary(forKey: "fields").bool(forKey: "tableQueue")
            else { return nil }
            
            self.id               = id
            self.title            = title
            self.publishDate      = publishDate
            self.url              = url
            self.postImageAssetID = json.dictionary(forKeys: "fields", "postImage", "sys").string(forKey: "id") ?? ""
            self.isInTable        = isInTable
            self.createdAt        = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt        = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
            self.type             = json.dictionary(forKey: "fields").enum(forKey: "type") ?? .post
        }
    }

}
