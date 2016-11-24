//: Playground - noun: a place where people can play

import Cocoa

let puzzleBegin = "wrbbrrbbrrbbrrbb"

puzzleBegin.replacingCharacters(in: puzzleBegin.startIndex..<puzzleBegin.startIndex, with: "s")
puzzleBegin[puzzleBegin.startIndex]

var frame = puzzleBegin
let previousIndex = frame.index(frame.startIndex, offsetBy: 0)
let nextIndex = frame.index(frame.startIndex, offsetBy: 1)
let previousBlock = frame[previousIndex]
let nextBlock = frame[nextIndex]
frame = frame.replacingCharacters(in: previousIndex..<frame.index(after: previousIndex), with: String(nextBlock))
frame = frame.replacingCharacters(in: nextIndex..<frame.index(after: nextIndex), with: String(previousBlock))
frame
