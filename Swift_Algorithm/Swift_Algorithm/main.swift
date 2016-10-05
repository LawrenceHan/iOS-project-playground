//
//  main.swift
//  Swift_Algorithm
//
//  Created by Hanguang on 10/5/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

print("Hello, World!")

var queue = Queue<String>()

print(queue)

queue.enqueue("Ada")
queue.enqueue("Steve")
queue.enqueue("Tim")
queue.enqueue("Lawrence")

print(queue)

_ = queue.dequeue()
print(queue)

_ = queue.dequeue()
print(queue)

_ = queue.dequeue()
print(queue)

_ = queue.peek()
print(queue)

let list = [ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67 ]
let newList = insertionSort(list) { $0 < $1 }
let matchIndex = binarySearch(newList, key: 43)

print(newList)
print(matchIndex)

let tree = BinarySearchTree<Int>(array: [7, 2, 5, 10, 9, 1])

print(tree)
print(tree.search(6))

tree.traverseInOrder { value in print(value) }
let filteredList = tree.filter { $0 < 7 }
print(filteredList)

print(tree.height())
