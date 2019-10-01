//
//  Contentful+Pantry.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Diakoneo

extension Contentful {
    
    struct Pantry {
        let id: String
        let title: String
        let shelfIDs: [String]
        let info: String
        let createdAt: Date
        let updatedAt: Date
        
        var shelves: [Contentful.Shelf] {
            var shelves: [Contentful.Shelf] = []
            
            for id in shelfIDs {
                if let shelf = Contentful.LocalStorage.shelves.first(where: { $0.id == id }) {
                    shelves.append(shelf)
                }
            }
            
            return shelves
        }
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title")
            else { return nil }
            
            self.id        = entry.id
            self.title     = title
            self.shelfIDs  = entry.fields.array(forKey: "shelves").dictionaries.compactMap { $0.dictionary(forKey: "sys").string(forKey: "id") }
            self.info      = entry.fields.string(forKey: "description") ?? ""
            self.createdAt = entry.createdAt
            self.updatedAt = entry.updatedAt
        }
    }

}
