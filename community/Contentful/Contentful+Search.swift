//
//  Contentful+Search.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import Diakoneo

extension Contentful {
    
    struct Search {
        let id: String
        let title: String
        let suggestions: [String]
        let createdAt: Date
        let updatedAt: Date
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title")
            else { return nil }
            
            self.id          = entry.id
            self.title       = title
            self.suggestions = entry.fields.array(forKey: "suggestions").strings
            self.createdAt   = entry.createdAt
            self.updatedAt   = entry.updatedAt
        }
    }
    
}
