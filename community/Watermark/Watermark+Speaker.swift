//
//  Watermark+Speaker.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

extension Watermark {
    
    struct Speaker: Initializable {
        let id: Int
        let isFeatured: Bool
        let name: String
        
        init?(json: [String : Any]) {
            guard
                let id = json.int(forKey: "id"),
                let isFeatured = json.bool(forKey: "featured"),
                let name = json.string(forKey: "name")
            else { return nil }
            
            self.id         = id
            self.isFeatured = isFeatured
            self.name       = name
        }
        
        var image: URL? {
            return Speaker.images[name]
        }
    }
    
}

extension Watermark.Speaker {
    
    static let images: [String : URL] = [
        "Todd Wagner"       : "http://cms-cloud.watermark.org/_tf100/Todd-Wagner_2016.jpg",
        "Jonathan Pokluda"  : "http://cms-cloud.watermark.org/_tf300/Jonathan-Pokluda_1.jpg",
        "Blake Holmes"      : "http://cms-cloud.watermark.org/_tf100/Blake-Holmes_1.jpg",
        "Adam Tarnow"       : "http://cms-cloud.watermark.org/_tf100/Adam-Tarnow.jpg",
        "Garrett Raburn"    : "http://cms-cloud.watermark.org/_tf300/Garrett-Raburn.jpg",
        "Rick Smith"        : "http://cms-cloud.watermark.org/_tf300/Rick-Smith.jpeg",
        "David Marvin"      : "http://cms-cloud.watermark.org/_tf300/David-Marvin_1.jpg",
        "Bobby Crotty"      : "http://cms-cloud.watermark.org/_tf300/Bobby-Crotty.jpg",
        "Nathan Wagnon"     : "http://cms-cloud.watermark.org/_tf300/Nathan-Wagnon.jpg",
        "Jeff Ward"         : "http://cms-cloud.watermark.org/_tf300/Jeff-Ward-2.jpg",
        "Tyler Briggs"      : "http://cms-cloud.watermark.org/_tf300/Tyler-Briggs.jpg",
        "Derek Mathews"     : "http://cms-cloud.watermark.org/_tf300/Derek-Mathews.jpg",
        "John Elmore"       : "http://cms-cloud.watermark.org/_tf300/John-Elmore_1.jpg",
        "Wes Butler"        : "http://cms-cloud.watermark.org/_tf300/Wes-Butler_1.jpg",
        "Beau Fournet"      : "http://cms-cloud.watermark.org/_tf300/Beau-Fornet.jpg",
        "Gary Stroope"      : "http://cms-cloud.watermark.org/_tf300/Gary-Stroope.jpg",
        "Jeff Parker"       : "http://cms-cloud.watermark.org/_tf300/Jeff-Parker.jpg"
    ]
    
}
