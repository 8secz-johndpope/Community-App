//
//  AVFoundation+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 1/26/19.
//

import UIKit
import AVFoundation

extension AVAudioSession {
    
    static func configureBackgroundAudio(isEnabled: Bool, category: AVAudioSession.Category = .playback) {
        if isEnabled {
            do {
                try sharedInstance().setCategory(category, mode: .default)
                try sharedInstance().setActive(true)
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            catch {
                print("""
                    ===========================================================================
                    
                    Error starting audio session: \(error.localizedDescription)
                    
                    ===========================================================================
                    """)
            }
        }
        else {
            do {
                UIApplication.shared.endReceivingRemoteControlEvents()
                try sharedInstance().setActive(false)
            }
            catch {
                print("""
                    ===========================================================================
                    
                    Error deactivating audio session: \(error.localizedDescription)
                    
                    ===========================================================================
                    """)
            }
        }
    }
    
}
