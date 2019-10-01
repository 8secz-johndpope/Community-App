//
//  Contentful+Author.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Diakoneo

extension Contentful {

    struct Author {
        let id: String
        let name: String
        let headShotAssetID: String
        let createdAt: Date
        let updatedAt: Date
        
        init?(entry: Contentful.Entry) {
            guard let title = entry.fields.string(forKey: "name") else { return nil }
            
            self.id              = entry.id
            self.name            = title
            self.headShotAssetID = entry.fields.dictionary(forKeys: "headShot", "sys").string(forKey: "id") ?? ""
            self.createdAt       = entry.createdAt
            self.updatedAt       = entry.updatedAt
        }
    }

}
