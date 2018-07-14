//
//  Contentful+Asset.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Contentful {
    
    struct Asset: Initializable {
        
        enum ContentType: String {
            case png       = "image/png"
            case jpg       = "image/jpeg"
            case mp3       = "audio/mp3"
            case mp4       = "video/mp4"
            case quicktime = "video/quicktime"
            case m4v       = "video/x-m4v"
            case mpeg      = "audio/mpeg"
            case unknown
        }
        
        let id: String
        let title: String
        let url: String
        let fileName: String
        let contentType: ContentType
        let createdAt: Date
        let updatedAt: Date
        
        init?(json: [String : Any]) {
            id          = json.dictionary(forKey: "sys").string(forKey: "id") ?? ""
            title       = json.dictionary(forKey: "fields").string(forKey: "title") ?? ""
            url         = json.dictionary(forKeys: "fields", "file").string(forKey: "url").flatMap { "https:" + $0 } ?? ""
            fileName    = json.dictionary(forKeys: "fields", "file").string(forKey: "fileName") ?? ""
            contentType = json.dictionary(forKeys: "fields", "file").enum(forKey: "contentType") ?? .unknown
            createdAt   = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            updatedAt   = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }

}
