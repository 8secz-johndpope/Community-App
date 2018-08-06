//
//  Int+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/17/18.
//

import Foundation

extension Int {
    
    var time: (hours: Int, minutes: Int, seconds: Int) {
        let hours = self / 3600
        let minutes = (self / 60) % 60
        let seconds = self % 60
        
        return (hours, minutes, seconds)
    }
    
    var timeString: String {
        
        let time = self.time
        
        guard time.hours >= 0, time.minutes >= 0, time.seconds >= 0 else { return "0:00" }
        
        if time.hours > 0 {
            return String(format: "%01d:%02d:%02d", time.hours, time.minutes, time.seconds)
        }
        else if time.minutes < 10 {
            return String(format: "%01d:%02d", time.minutes, time.seconds)
        }
        else {
            return String(format: "%02d:%02d", time.minutes, time.seconds)
        }
    }
    
}
