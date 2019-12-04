//
//  Contentful+FeaturedSection.swift
//  community
//
//  Created by Jonathan Landon on 12/3/19.
//

import Foundation
import Diakoneo

extension Contentful {
    
    struct FeaturedSection {
        let id: String
        let title: String
        let content: DeepLink
        let info: String
        let createdAt: Date
        let updatedAt: Date
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title"),
                let contentID = entry.fields.string(forKeys: "content", "sys", "id")
            else { return nil }
            
            self.id          = entry.id
            self.title       = title
            self.content     = .entry(contentID)
            self.info        = entry.fields.string(forKey: "description") ?? ""
            self.createdAt   = entry.createdAt
            self.updatedAt   = entry.updatedAt
        }
    }
    
}
