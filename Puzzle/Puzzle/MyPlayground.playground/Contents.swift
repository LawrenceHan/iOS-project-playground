//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
let availableCPUCount: Int = 8;
let routesCount = 34;
var groupCount = routesCount / availableCPUCount + 1
var indexOffset = groupCount * 0
var beginIndex = 0 + indexOffset
var endIndex = (groupCount - 1) + indexOffset
