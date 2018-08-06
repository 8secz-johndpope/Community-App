//
//  Extensions.swift
//  CommonMark
//
//  Created by Jonathan Landon on 9/10/16.
//  Copyright © 2016 Jonathan Landon. All rights reserved.
//

import Foundation
import cmark

infix operator ?= : AssignmentPrecedence

public func ?=<T>(lhs: inout T, rhs: T?) {
    if let value = rhs {
        lhs = value
    }
}

public func ?=<T>(lhs: inout T?, rhs: T?) {
    if let value = rhs {
        lhs = value
    }
}

extension String {
    init?(unsafeCString: UnsafePointer<Int8>!) {
        guard let cString = unsafeCString else { return nil }
        self.init(cString: cString)
    }
}

extension Sequence where Iterator.Element == Block {
    var nodes: [Node] {
        return map { $0.node }
    }
}

extension Sequence where Iterator.Element == [Block] {
    var nodes: [Node] {
        return map { Node(type: CMARK_NODE_ITEM, children: $0.nodes) }
    }
}

extension Sequence where Iterator.Element == Inline {
    var nodes: [Node] {
        return map { $0.node }
    }
}

extension Sequence where Iterator.Element == Node {
    var inlines: [Inline] {
        return map { $0.inline }
    }
    var blocks: [Block] {
        return map { $0.block }
    }
    var list: [[Block]] {
        return map { $0.listItem }
    }
}
