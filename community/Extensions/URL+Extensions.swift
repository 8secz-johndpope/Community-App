//
//  URL+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation
import MobileCoreServices

extension URL {
    
    public init(base: URL, parameters: [String : String]) {
        guard let components = URLComponents(url: base, parameters: parameters), let url = components.url
        else { fatalError("URL could not be created: \(base), with parameters: \(parameters)") }
        
        self = url
    }
    
    public var components: URLComponents? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)
    }
    
    var isAudio: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            lastPathComponent.ns.pathExtension.lowercased() as CFString,
            nil
        )?.takeRetainedValue() else { return false }
        
        return UTTypeConformsTo(uti, kUTTypeAppleProtectedMPEG4Audio) ||
               UTTypeConformsTo(uti, kUTTypeMPEG4Audio) ||
               UTTypeConformsTo(uti, kUTTypeMP3)
    }
    
    var isVideo: Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            lastPathComponent.ns.pathExtension.lowercased() as CFString,
            nil
        )?.takeRetainedValue() else { return false }
        
        return UTTypeConformsTo(uti, kUTTypeVideo) ||
               UTTypeConformsTo(uti, kUTTypeQuickTimeMovie) ||
               UTTypeConformsTo(uti, kUTTypeMPEG) ||
               UTTypeConformsTo(uti, kUTTypeMPEG4)
    }
    
}
