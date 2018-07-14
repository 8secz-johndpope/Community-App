//
//  Watermark+Pagination.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Watermark {

    struct Pagination: Initializable {
        let total: Int
        let size: Int
        let limit: Int
        let offset: Int
        
        init?(json: [String : Any]) {
            guard
                let total = json.int(forKey: "total"),
                let size = json.int(forKey: "size"),
                let limit = json.int(forKey: "limit"),
                let offset = json.int(forKey: "offset")
            else { return nil }
            
            self.total  = total
            self.size   = size
            self.limit  = limit
            self.offset = offset
        }
    }

}
