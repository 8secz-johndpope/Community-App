//
//  MediaPlayer+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import MediaPlayer
import Diakoneo

extension MPNowPlayingInfoCenter {
    
    static func update(textPost: Contentful.TextPost, image: UIImage?, currentTime: TimeInterval, duration: TimeInterval) {
        update(
            title: textPost.title,
            organization: nil,
            author: textPost.authors.map { $0.name }.joined(separator: ", "),
            url: textPost.mediaURL,
            image: image,
            currentTime: currentTime,
            duration: duration
        )
    }
    
}
