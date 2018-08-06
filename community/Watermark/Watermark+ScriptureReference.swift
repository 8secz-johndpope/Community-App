//
//  Watermark+ScriptureReference.swift
//  community
//
//  Created by Jonathan Landon on 7/17/18.
//

import Foundation

extension Watermark {
    
    struct ScriptureReference: Initializable {
        let id: Int
        let bookID: Int
        let bookName: String
        let verses: String
        
        var reference: String {
            return [bookName, verses].joined(separator: " ")
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let bookID = json.int(forKey: "book_id"),
                let bookName = json.string(forKey: "book_name"),
                let verses = json.string(forKey: "verses")
            else { return nil }
            
            self.id       = id
            self.bookID   = bookID
            self.bookName = bookName
            self.verses   = verses
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case bookID   = "book_id"
            case bookName = "book_name"
            case verses
        }
        
        init(id: Int = Int.random(1000...9999), bookID: Int = 0, bookName: String, verses: String) {
            self.id       = id
            self.bookID   = bookID
            self.bookName = bookName
            self.verses   = verses
        }
    }

}
