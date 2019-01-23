//
//  Contentful+Question.swift
//  community
//
//  Created by Jonathan Landon on 10/20/18.
//

import Foundation

extension Contentful {
    
    struct Question: Initializable {
        let id: String
        let question: String
        let info: String
        let createdAt: Date
        let updatedAt: Date
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let question = json.dictionary(forKey: "fields").string(forKey: "question")
            else { return nil }
            
            self.id        = id
            self.question  = question
            self.info      = json.dictionary(forKey: "fields").string(forKey: "description") ?? ""
            self.createdAt = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }
    
}
