//
//  Contentful+Intro.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import Diakoneo

extension Contentful {
    
    struct Intro {
        let id: String
        let title: String
        let videoURL: URL
        let createdAt: Date
        let updatedAt: Date
        
        init?(entry: Contentful.Entry) {
            guard
                let title = entry.fields.string(forKey: "title"),
                let videoURL = entry.fields.url(forKey: "videoUrl")
            else { return nil }
            
            self.id        = entry.id
            self.title     = title
            self.videoURL  = videoURL
            self.createdAt = entry.createdAt
            self.updatedAt = entry.updatedAt
        }
    }
    
}
