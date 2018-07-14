//
//  Watermark+Asset.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Watermark {
    
    struct ImageAsset: Initializable, CustomStringConvertible {
        let id: Int
        let url: URL
        
        var description: String {
            return url.absoluteString
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let url = json.url(forKey: "url")
            else { return nil }
            
            self.id  = id
            self.url = url
        }
        
        enum Size: String, CustomStringConvertible {
            case banner
            case square
            case wide
            
            var description: String {
                return rawValue
            }
        }
    }

    struct VideoAsset: Initializable {
        let id: Int
        let url: URL
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let url = json.url(forKey: "url")
            else { return nil }
            
            self.id  = id
            self.url = url
        }
    }

    struct AudioAsset: Initializable {
        let id: Int
        let url: URL
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let url = json.url(forKey: "url")
            else { return nil }
            
            self.id  = id
            self.url = url
        }
    }

}
