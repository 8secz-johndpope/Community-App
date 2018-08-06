//
//  Operators.swift
//  community
//
//  Created by Jonathan Landon on 7/16/18.
//

import Foundation

infix operator ?= : AssignmentPrecedence

func ?=<T>(lhs: inout T, rhs: T?) {
    if let value = rhs {
        lhs = value
    }
}

func ?=<T>(lhs: inout T?, rhs: T?) {
    if let value = rhs {
        lhs = value
    }
}
