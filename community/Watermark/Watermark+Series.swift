//
//  Watermark+Series.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Watermark {
    
    struct SeriesResponse: Initializable {
        let series: [Series]
        let pagination: Pagination
        
        init?(json: [String : Any]) {
            guard let pagination: Pagination = json.initialize(forKey: "pagination") else { return nil }
            
            self.series   = json.array(forKey: "series")
            self.pagination = pagination
        }
    }

    struct Series: Initializable, CustomStringConvertible {
        let id: Int
        let title: String
        let subtitle: String
        let summary: String
        let images: [ImageAsset.Size : ImageAsset]
        let messageCount: Int
        let dateRange: [Date]
        
        var latestDate: Date {
            return dateRange.last ?? Date()
        }
        
        var wideImage: ImageAsset? {
            return images[.wide]
        }
        
        var image: ImageAsset? {
            return wideImage ?? images.first?.value
        }
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let title = json.string(forKey: "title"),
                let subtitle = json.string(forKey: "subtitle"),
                let summary = json.string(forKey: "summary"),
                let messageCount = json.int(forKey: "messages_count")
            else { return nil }
            
            self.id           = id
            self.title        = title
            self.subtitle     = subtitle
            self.summary      = summary
            self.messageCount = messageCount
            self.images       = Dictionary.flatten([
                .banner : json.dictionary(forKey: "images").initialize(forKey: "banner"),
                .square : json.dictionary(forKey: "images").initialize(forKey: "square"),
                .wide   : json.dictionary(forKey: "images").initialize(forKey: "wide"),
            ])
            self.dateRange = json.array(forKey: "date_range")
                .compactMap { $0 as? String }
                .compactMap { DateFormatter.yearMonthDay.date(from: $0) }
                .sorted(by: <)
            
            if self.images.isEmpty {
                return nil
            }
            
            let excludedSeries: [String] = [
                "re|engage Testimonies",
                "Re-Engage",
                "Fort Worth: Conflict",
                "Plano: The Outsiders",
                "Launch 2016",
                "Launch 2017",
                "Launch 2018"
            ]
            
            if excludedSeries.contains(title) {
                return nil
            }
        }
        
        var description: String {
            return "\(title), count: \(messageCount)"
        }
        
    }

}
