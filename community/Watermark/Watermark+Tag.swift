//
//  Watermark+Tag.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Watermark {
    
    struct Tag: Initializable {
        let id: Int
        let name: String
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let name = json.string(forKey: "name")
            else { return nil }
            
            self.id   = id
            self.name = name
        }
    }
    
}
