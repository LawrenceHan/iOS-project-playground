//
//  InsertionSort.swift
//  Swift_Algorithm
//
//  Created by Hanguang on 10/5/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public func insertionSort<T>(_ array: [T], _ isOrderedBefore: (T, T) -> Bool) -> [T] {
    var a = array
    for x in 1 ..< a.count {
        var y = x
        let temp = a[y]
        while y > 0 && isOrderedBefore(temp, a[y - 1]) {
            a[y] = a[y - 1]
            y -= 1
        }
        a[y] = temp
    }
    return a
}
