//
//  BinarySearchTreeEnum.swift
//  Swift_Algorithm
//
//  Created by Hanguang on 10/6/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public enum BinarySearchTreeEnum<T: Comparable> {
    case Empty
    case Leaf(T)
    indirect case Node(BinarySearchTreeEnum, T, BinarySearchTreeEnum)
    
    public var count:Int {
        switch self {
        case .Empty: return 0
        case .Leaf: return 1
        case let .Node(left, _, right): return left.count + 1 + right.count
        }
    }
    
    public var height: Int {
        switch self {
        case .Empty: return 0
        case .Leaf: return 1
        case let .Node(left, _, right): return 1 + max(left.height, right.height)
        }
    }
    
    public func insert(_ newValue: T) -> BinarySearchTreeEnum {
        switch self {
        case .Empty:
            return .Leaf(newValue)
            
        case .Leaf(let value):
            if newValue < value {
                return .Node(.Leaf(newValue),  value, .Empty)
            } else {
                return .Node(.Empty, value, .Leaf(newValue))
            }
            
        case .Node(let left, let value, let right):
            if newValue < value {
                return .Node(left.insert(newValue), value, right)
            } else {
                return .Node(left, value, right.insert(newValue))
            }
        }
    }
    
    public func search(_ x: T) -> BinarySearchTreeEnum? {
        switch self {
        case .Empty:
            return nil
        case .Leaf(let y):
            return (x == y) ? self : nil
        case let .Node(left, y, right):
            if x < y {
                return left.search(x)
            } else if y < x {
                return right.search(x)
            } else {
                return self
            }
        }
    }
}

extension BinarySearchTreeEnum: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Empty: return "."
        case .Leaf(let value): return "\(value)"
        case .Node(let left, let value, let right):
            return "(\(left.debugDescription) <- \(value) -> \(right.debugDescription))"
        }
    }
}
