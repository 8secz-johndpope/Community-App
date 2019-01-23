//
//  Contentful+Search.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import Foundation

extension Contentful {
    
    struct Search: Initializable {
        let id: String
        let title: String
        let suggestions: [String]
        let createdAt: Date
        let updatedAt: Date
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title")
            else { return nil }
            
            self.id          = id
            self.title       = title
            self.suggestions = json.dictionary(forKey: "fields").array(forKey: "suggestions").strings
            self.createdAt   = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt   = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }
    
}
