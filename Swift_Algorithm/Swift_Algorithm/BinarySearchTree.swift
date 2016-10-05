//
//  BinarySearchTree.swift
//  Swift_Algorithm
//
//  Created by Hanguang on 10/5/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public class BinarySearchTree<T: Comparable> {
    //MARK: Private property
    
    private(set) public var value: T
    private(set) public var parent: BinarySearchTree?
    private(set) public var left: BinarySearchTree?
    private(set) public var right: BinarySearchTree?
    
    //MARK: Init mehtod
    
    public init(value: T) {
        self.value = value
    }
    
    public convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(value: array.first!)
        for v in array.dropFirst() {
            insert(value: v, parent: self)
        }
    }
    
    //MARK: Public property
    
    public var isRoot: Bool {
        return parent == nil
    }
    
    public var isLeaf: Bool {
        return left == nil && right == nil
    }
    
    public var isLeftChild: Bool {
        return parent?.left === self
    }
    
    public var isRightChild: Bool {
        return parent?.right === self
    }
    
    public var hasLeftChild: Bool {
        return left != nil
    }
    
    public var hasRightChild: Bool {
        return right != nil
    }
    
    public var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }
    
    public var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }
    
    public var count: Int {
        return (left?.count ?? 0) + 1 + (right?.count ?? 0)
    }
    
    //MARK: Public methods
    
    public func insert(value: T) {
        insert(value: value, parent: self)
    }
    
    public func search(_ value: T) -> BinarySearchTree? {
        var node: BinarySearchTree? = self
        while case let n? = node {
            if value < n.value {
                node = n.left
            } else if value > n.value {
                node = n.right
            } else {
                return node
            }
        }
        return nil
    }
    
    public func traverseInOrder(process: (T) -> Void) {
        left?.traverseInOrder(process: process)
        process(value)
        right?.traverseInOrder(process: process)
    }
    
    public func traversePerOrder(process: (T) -> Void) {
        process(value)
        left?.traversePerOrder(process: process)
        right?.traversePerOrder(process: process)
    }
    
    public func traversePostOrder(process: (T) -> Void) {
        left?.traversePostOrder(process: process)
        right?.traversePostOrder(process: process)
        process(value)
    }
    
    public func map(formula: (T) -> T) -> [T] {
        var a = [T]()
        if let left = left { a += left.map(formula: formula) }
        a.append(formula(value))
        if let right = right { a += right.map(formula: formula) }
        return a
    }
    
    public func filter(formula: (T) -> Bool) -> [T] {
        var a = [T]()
        if let left = left { a += left.filter(formula: formula) }
        if formula(value) { a.append(value) }
        if let right = right { a += right.filter(formula: formula) }
        return a
    }
    
    //TODO: Add Reduce method
    
    
    public func toArray() -> [T] {
        return map { $0 }
    }
    
    public func minimum() -> BinarySearchTree {
        var node = self
        while case let next? = node.left {
            node = next
        }
        return node
    }
    
    public func maximum() -> BinarySearchTree {
        var node = self
        while case let next? = node.right {
            node = next
        }
        return node
    }
    
    public func remove() -> BinarySearchTree? {
        let replacement: BinarySearchTree?
        
        if let left = left {
            if let right = right {
                replacement = removeNodeWithTwoChildren(left, right)
            } else {
                replacement = left
            }
        } else if let right = right {
            replacement = right
        } else {
            replacement = nil
        }
        
        reconnectParentToNode(node: replacement)
        
        parent = nil
        left = nil
        right = nil
        
        return replacement
    }
    
    public func height() -> Int {
        if isLeaf {
            return 0
        } else {
            return 1 + max(left?.height() ?? 0, right?.height() ?? 0)
        }
    }
    
    public func depth() -> Int {
        var node = self
        var edges = 0
        while case let parent? = node.parent {
            node = parent
            edges += 1
        }
        return edges
    }
    
    public func predecessor() -> BinarySearchTree<T>? {
        if let left = left {
            return left.maximum()
        } else {
            var node = self
            while case let parent? = node.parent {
                if parent.value < value { return parent }
                node = parent
            }
            return nil
        }
    }
    
    //MARK: Private methods
    
    private func insert(value: T, parent: BinarySearchTree) {
        if value < self.value {
            if let left = left {
                left.insert(value: value, parent: left)
            } else {
                left = BinarySearchTree(value: value)
                left?.parent = parent
            }
        } else {
            if let right = right {
                right.insert(value: value, parent: right)
            } else {
                right = BinarySearchTree(value: value)
                right?.parent = parent
            }
        }
    }
    
    private func reconnectParentToNode(node: BinarySearchTree?) {
        if let parent = parent {
            if isLeftChild {
                parent.left = node
            } else {
                parent.right = node
            }
        }
        node?.parent = parent
    }

    private func removeNodeWithTwoChildren(_ left: BinarySearchTree, _ right: BinarySearchTree) -> BinarySearchTree {
        let successor = right.minimum()
        _ = successor.remove()
        
        successor.left = left
        left.parent = successor
        
        if right !== successor {
            right.parent = successor
        } else {
            successor.right = nil
        }
        
        return successor
    }
}

extension BinarySearchTree: CustomStringConvertible {
    public var description: String {
        var s = ""
        if let left = left {
            s += "(\(left.description)) <- "
        }
        s += "\(value)"
        if let right = right {
            s += " -> (\(right.description))"
        }
        return s
    }
}

