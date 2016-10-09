//
//  BoyerMooreString.swift
//  Swift_algorithm
//
//  Created by Hanguang on 10/7/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

extension String {
    /*
    public func indexOf(_ pattern: String) -> String.Index? {
        let patternLength = pattern.characters.count
        assert(patternLength > 0)
        assert(patternLength <= self.characters.count)
        
        var skipTable = [Character : Int]()
        for (i, c) in pattern.characters.enumerated() {
            skipTable[c] = patternLength - i - 1
        }
        
        let p = pattern.index(before: pattern.endIndex)
        let lastChar = pattern[p]
        
        var i = self.index(self.startIndex, offsetBy: patternLength - 1)
        
        func backwards() -> String.Index? {
            var q = p
            var j = i
            while q > pattern.startIndex {
                j = index(before: j)
                q = index(before: q)
                if self[j] != pattern[q] { return nil }
            }
            return j
        }
        
        while i < self.endIndex {
            let c = self[i]
            if c == lastChar {
                if let k = backwards() { return k }
                i = index(after: i)
            } else {
                i = index(i, offsetBy: skipTable[c] ?? patternLength)
            }
        }
        return nil
    }
 */
    
    public func indexOf(_ pattern: String) -> String.Index? {
        let patternLength = pattern.characters.count
        assert(patternLength > 0)
        assert(patternLength < self.characters.count)
        
        var skipTable = [Character: Int]()
        for (i, c) in pattern.characters.dropLast().enumerated() {
            skipTable[c] = patternLength - i - 1
        }
        
        var idx = index(self.startIndex, offsetBy: patternLength - 1)
        
        while idx < self.endIndex {
            var i = idx
            var p = index(before: pattern.endIndex)
            
            while self[i] == pattern[p] {
                if p == pattern.startIndex { return i }
                i = index(before: i)
                p = index(before: p)
            }
            
            let advance = skipTable[self[idx]] ?? patternLength
            idx = index(idx, offsetBy: advance)
        }
        
        return nil
    }
}

