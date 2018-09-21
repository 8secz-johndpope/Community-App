//
//  Timer+Extensions.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import Foundation

extension Timer {
    
    @discardableResult
    static func every(_ interval: TimeInterval, closure: @escaping () -> Void) -> Timer {
        let timer = Timer(timeInterval: interval, repeats: true) { _ in closure() }
        timer.start()
        return timer
    }
    
    @discardableResult
    static func once(after interval: TimeInterval, closure: @escaping () -> Void) -> Timer {
        let timer = Timer(timeInterval: interval, repeats: false) { _ in closure() }
        timer.start()
        return timer
    }
    
    func start(runLoop: RunLoop = .main, modes: [RunLoop.Mode] = [.common]) {
        for mode in modes {
            runLoop.add(self, forMode: mode)
        }
    }
    
}
