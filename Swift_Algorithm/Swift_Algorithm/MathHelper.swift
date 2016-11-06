//
//  GreatestCommonDivisor.swift
//  Swift_algorithm
//
//  Created by Hanguang on 15/10/2016.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public func gcd(_ m: Int, _ n: Int) -> Int {
    var a = 0
    var b = max(m, n)
    var r = min(m, n)
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

public func lcm(_ m: Int, _ n: Int) -> Int {
    return m * n / gcd(m, n)
}
