//: Playground - noun: a place where people can play

import Cocoa
var str = "Hello, playground"

let playground = "Hello, playground"
var mutablePlayground = "Hello, mutable playground"
mutablePlayground += "!"
for c: Character in mutablePlayground.characters {
    print("\(c)")
}
let oneCoolDude = "\u{1F60E}"
let aAcute = "\u{0061}\u{0301}"
for scalar in playground.unicodeScalars {
    print("\(scalar.value)")
}

let aAcutePrecomposed = "\u{00E1}"

let b = (aAcute == aAcutePrecomposed) // true
print("aAcute: \(aAcute.characters.count); aAcuteDecomposed: \(aAcutePrecomposed.characters.count)")

let fromStart = playground.startIndex
let toPosition = 4 // Th
