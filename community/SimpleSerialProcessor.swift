//
//  SimpleSerialProcessor.swift
//  community
//
//  Created by Jonathan Landon on 7/14/18.
//

import Foundation

struct SimpleSerialProcessor {
    
    private let queue = DispatchQueue(label: "com.ovenbits.alexandria.simpleserialprocessor")
    
    init() {}
    
    /**
     Add your task to the end of the queue which will be executed in the order it was added.
     
     parameter block: Where your long running task should be executed. The `dequeue` closure parameter
     of this block must be called upon completion of your task to allow the next task to occur.
     */
    func enqueue(_ block: @escaping (@escaping () -> Void) -> Void) {
        let group = DispatchGroup()
        
        queue.async {
            group.enter()
            block { group.leave() }
            _ = group.wait(timeout: .distantFuture)
        }
    }
}
