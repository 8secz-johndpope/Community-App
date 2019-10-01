//
//  Contentful+Question.swift
//  community
//
//  Created by Jonathan Landon on 10/20/18.
//

import Diakoneo

extension Contentful {
    
    struct Question {
        let id: String
        let question: String
        let info: String
        let createdAt: Date
        let updatedAt: Date
        
        init?(entry: Contentful.Entry) {
            guard
                let question = entry.fields.string(forKey: "question")
            else { return nil }
            
            self.id        = entry.id
            self.question  = question
            self.info      = entry.fields.string(forKey: "description") ?? ""
            self.createdAt = entry.createdAt
            self.updatedAt = entry.updatedAt
        }
    }
    
}
