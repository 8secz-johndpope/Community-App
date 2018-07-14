//
//  Contentful+Author.swift
//  community
//
//  Created by Jonathan Landon on 7/13/18.
//

import Foundation

extension Contentful {

    struct Author: Initializable {
        let id: String
        let name: String
        let headShotAssetID: String
        let createdAt: Date
        let updatedAt: Date
        
        init?(json: [String : Any]) {
            guard
                let id = json.dictionary(forKey: "sys").string(forKey: "id"),
                let name = json.dictionary(forKey: "fields").string(forKey: "name")
            else { return nil }
            
            self.id              = id
            self.name            = name
            self.headShotAssetID = json.dictionary(forKeys: "fields", "headShot", "sys").string(forKey: "id") ?? ""
            self.createdAt       = json.dictionary(forKey: "sys").date(forKey: "createdAt", formatter: .iso8601) ?? Date()
            self.updatedAt       = json.dictionary(forKey: "sys").date(forKey: "updatedAt", formatter: .iso8601) ?? Date()
        }
    }

}
