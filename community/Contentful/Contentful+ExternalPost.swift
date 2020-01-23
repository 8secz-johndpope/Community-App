//
//  Contentful+ExternalPost.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation
import Diakoneo

extension Contentful {
    
    struct ExternalPost {
        let id: String
        let title: String
        let publishDate: Date
        let url: URL
        let postImageAssetID: String
        let createdAt: Date
        let updatedAt: Date
        let type: PostType
        
        var image: Contentful.Asset? {
            return Contentful.LocalStorage.assets.first(where: { $0.id == postImageAssetID })
        }
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title"),
                let publishDate = entry.fields.date(forKey: "publishDate", formatter: .yearMonthDay),
                let url = entry.fields.url(forKey: "url") ?? entry.fields.url(forKey: "url", encode: true),
                publishDate < Date()
            else { return nil }
            
            self.id               = entry.id
            self.title            = title
            self.publishDate      = publishDate
            self.url              = url
            self.postImageAssetID = entry.fields.dictionary(forKeys: "postImage", "sys").string(forKey: "id") ?? ""
            self.createdAt        = entry.createdAt
            self.updatedAt        = entry.updatedAt
            self.type             = entry.fields.enum(forKey: "type") ?? .post
        }
    }

}
