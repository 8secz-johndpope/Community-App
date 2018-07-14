//
//  Contentful+Pantry.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Contentful {
    
    struct Pantry: Initializable {
        let id: String
        let title: String
        let shelfIDs: [String]
        let createdAt: Date
        let updatedAt: Date
        
        var shelves: [Contentful.Shelf] {
            return Contentful.LocalStorage.shelves.filter { shelfIDs.contains($0.id) }
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let title = json.dictionary(forKey: "fields").string(forKey: "title")
            else { return nil }
            
            self.id        = id
            self.title     = title
            self.shelfIDs  = json.dictionary(forKey: "fields").array(forKey: "shelves").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.createdAt = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }

}
