//
//  Vertex.swift
//  Swift_Algorithm
//
//  Created by Hanguang on 23/11/2016.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public struct Vertex<T>: Equatable where T: Equatable, T: Hashable {
    
    public var data: T
    public let index: Int
    
}

extension Vertex: CustomStringConvertible {
    
    public var description: String {
        get {
            return "\(index): \(data)"
        }
    }
}

extension Vertex: Hashable {
    
    public var hashValue: Int {
        get {
            return "\(data)\(index)".hashValue
        }
    }
}

public func ==<T: Equatable>(lhs: Vertex<T>, rhs: Vertex<T>) -> Bool {
    guard lhs.index == rhs.index else {
        return false
    }
    
    guard lhs.data == rhs.data else {
        return false
    }
    
    return true
}
