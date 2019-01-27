//
//  MediaPlayer+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 1/21/19.
//

import MediaPlayer

extension MPNowPlayingInfoCenter {
    
    static func update(textPost: Contentful.TextPost, image: UIImage?, currentTime: TimeInterval, duration: TimeInterval) {
        update(
            title: textPost.title,
            organization: nil,
            author: textPost.author?.name,
            url: textPost.mediaURL,
            image: image,
            currentTime: currentTime,
            duration: duration
        )
    }
    
    static func update(message: Watermark.Message?, image: UIImage?, currentTime: TimeInterval, duration: TimeInterval) {
        update(
            title: message?.title,
            organization: message?.series.title,
            author: message?.speakers.map({ $0.name }).joined(separator: ", "),
            url: message?.mediaAsset.url,
            image: image,
            currentTime: currentTime,
            duration: duration
        )
    }
    
    static func update(title: String?, organization: String?, author: String?, url: URL?, image: UIImage?, currentTime: TimeInterval, duration: TimeInterval) {
        
        guard
            let title = title,
            let url = url,
            duration > 0
        else { return }
        
        var info: [String : Any] = Dictionary.flatten([
            MPMediaItemPropertyTitle : title,
            MPMediaItemPropertyAlbumTitle : organization,
            MPMediaItemPropertyArtist : author,
            MPNowPlayingInfoPropertyElapsedPlaybackTime : NSNumber(value: currentTime),
            MPMediaItemPropertyPlaybackDuration : NSNumber(value: duration),
            MPMediaItemPropertyAssetURL : url
        ])
        
        if let image = image {
            print("Image: \(image)")
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
        }
        else {
            print("No image")
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
}
