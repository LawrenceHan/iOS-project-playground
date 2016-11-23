//
//  Edge.swift
//  Swift_Algorithm
//
//  Created by Hanguang on 23/11/2016.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public struct Edge<T>: Equatable where T: Equatable, T: Hashable {
    
    public let from: Vertex<T>
    public let to: Vertex<T>
    
    public let weight: Double?
    
}

extension Edge: CustomStringConvertible {
    
    public var description: String {
        get {
            guard let unwrappedWeight = weight else {
                return "\(from.description) -> \(to.description)"
            }
            return "\(from.description) -(\(unwrappedWeight))-> \(to.description)"
        }
    }
}

extension Edge: Hashable {
    
    public var hashValue: Int {
        get {
            var string = "\(from.description)\(to.description)"
            if weight != nil {
                string.append("\(weight)")
            }
            return string.hashValue
        }
    }
}

public func == <T>(lhs: Edge<T>, rhs: Edge<T>) -> Bool {
    guard lhs.from == rhs.from else {
        return false
    }
    
    guard lhs.to == rhs.to else {
        return false
    }
    
    guard lhs.weight == rhs.weight else {
        return false
    }
    
    return true
}
