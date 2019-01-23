//
//  Contentful+CommunityQuestions.swift
//  community
//
//  Created by Jonathan Landon on 10/20/18.
//

import Foundation

extension Contentful {
    
    struct CommunityQuestions: Initializable {
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
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title")
            else { return nil }
            
            self.id          = id
            self.title       = title
            self.questionIDs = json.dictionary(forKey: "fields").array(forKey: "questions").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.info        = json.dictionary(forKeys: "fields").string(forKey: "description") ?? ""
            self.createdAt   = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt   = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }
    
}
