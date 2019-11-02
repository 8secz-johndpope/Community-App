//
//  Contentful+CommunityQuestions.swift
//  community
//
//  Created by Jonathan Landon on 10/20/18.
//

import Foundation
import Diakoneo

extension Contentful {
    
    struct CommunityQuestions {
        let id: String
        let title: String
        let questionIDs: [String]
        let info: String
        let createdAt: Date
        let updatedAt: Date
        
        var questions: [Contentful.Question] {
            var questions: [Contentful.Question] = []

            let storedQuestions = Contentful.LocalStorage.questions

            for id in questionIDs {
                if let question = storedQuestions.first(where: { $0.id == id }) {
                    questions.append(question)
                }
            }

            return questions
        }
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title")
            else { return nil }
            
            self.id          = entry.id
            self.title       = title
            self.questionIDs = entry.fields.array(forKey: "questions").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.info        = entry.fields.string(forKey: "description") ?? ""
            self.createdAt   = entry.createdAt
            self.updatedAt   = entry.updatedAt
        }
    }
    
}
