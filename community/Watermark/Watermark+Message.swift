//
//  Watermark+Message.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Watermark {
    
    struct MessageResponse: Initializable {
        let messages: [Message]
        let pagination: Pagination
        
        init?(json: [String : Any]) {
            guard let pagination: Pagination = json.initialize(forKey: "pagination") else { return nil }
            
            self.messages   = json.array(forKey: "messages")
            self.pagination = pagination
        }
    }

    struct Message: Initializable {
        let id: Int
        let title: String
        let date: Date
        let details: String
        let speakers: [Speaker]
        let tags: [Tag]
        let series: Series
        let seriesIndex: Int
        let progressiveVideoAsset: VideoAsset?
        let streamingVideoAsset: VideoAsset?
        let audioAsset: AudioAsset?
        let images: [ImageAsset.Size : ImageAsset]
        
        var wideImage: ImageAsset? {
            return images[.wide]
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let title = json.string(forKey: "title"),
                let date = json.date(forKey: "date", formatter: .yearMonthDay),
                let details = json.string(forKey: "description"),
                let series: Series = json.initialize(forKey: "series"),
                let seriesIndex = json.int(forKey: "series_position")
            else { return nil }
            
            self.id                    = id
            self.title                 = title
            self.date                  = date
            self.details               = details
            self.speakers              = json.array(forKey: "speakers")
            self.tags                  = json.array(forKey: "tags")
            self.series                = series
            self.seriesIndex           = seriesIndex
            self.progressiveVideoAsset = json.dictionary(forKey: "assets").initialize(forKey: "progressive_video")
            self.streamingVideoAsset   = json.dictionary(forKey: "assets").initialize(forKey: "streaming_video")
            self.audioAsset            = json.dictionary(forKey: "assets").initialize(forKey: "audio")
            self.images                = Dictionary.flatten([
                .banner : json.dictionary(forKey: "images").initialize(forKey: "banner"),
                .square : json.dictionary(forKey: "images").initialize(forKey: "square"),
                .wide   : json.dictionary(forKey: "images").initialize(forKey: "wide"),
            ])
        }
        
    }

}
