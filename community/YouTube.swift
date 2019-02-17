//
//  YouTube.swift
//  community
//
//  Created by Jonathan Landon on 1/18/19.
//

import Foundation

public struct YouTube {
    
    enum Quality: Int {
        case small240  = 36
        case medium360 = 18
        case hd720     = 22
        
        static let preferred: [Quality] = [.hd720, .medium360, .small240]
    }
    
    public static func fetchVideo(url: URL?, completion: @escaping (URL?) -> Void = { _ in }) {
        let components = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        let id = components?.queryItems?.first(where: { $0.name == "v" })?.value
        fetchVideo(id: id, completion: completion)
    }
    
    public static func fetchVideo(id: String?, completion: @escaping (URL?) -> Void = { _ in }) {
        
        guard let id = id, let url = URL(string: "https://www.youtube.com/get_video_info?video_id=\(id)") else {
            return completion(nil)
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard
                let data = data,
                let responseString = String(data: data, encoding: .utf8)
            else { return completion(nil) }
            
            let info = dictionary(fromQuery: responseString)
            
            let streamMap = info["url_encoded_fmt_stream_map"] ?? ""
            let adaptiveFormats = info["adaptive_fmts"] ?? ""
            
            var streamQueries = streamMap.components(separatedBy: ",")
            streamQueries += adaptiveFormats.components(separatedBy: ",")
            
            var streamURLs: [Int : URL] = [:]
            
            for streamQuery in streamQueries {
                let stream = dictionary(fromQuery: streamQuery)
                
                if let urlString = stream["url"], let itag = Int(stream["itag"] ?? "") {
                    streamURLs[itag] = URL(string: urlString)
                }
            }
            
            for quality in Quality.preferred {
                if let streamURL = streamURLs[quality.rawValue] {
                    completion(streamURL)
                    return
                }
            }
            
            completion(nil)
            
        }.resume()
    }
}

private func dictionary(fromQuery string: String) -> [String : String] {
    var dictionary: [String : String] = [:]
    
    for field in string.components(separatedBy: "&") {
        let pair = field.components(separatedBy: "=")
        if pair.count == 2 {
            let key = pair[0]
            let value = (pair[1].removingPercentEncoding ?? "").replacingOccurrences(of: "+", with: " ")
            dictionary[key] = value
        }
    }
    
    return dictionary
}
