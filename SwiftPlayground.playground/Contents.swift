//: Playground - noun: a place where people can play

import Cocoa

// MARK: - Charpter 1

var str = "Hello, playground"
str += "!"
print(str)
print("Lawrence")

// MARK: - Charpter 2

let numberOfStopLights: Int = 4
var population: Int
population = 5422
let townName: String = "Knowhere"
let townDescription = "\(townName) has a population of \(population) and \(numberOfStopLights) stoplights."
print(townDescription)

// MARK: - Charpter 4 Numbers

print("The maximum Int value is \(Int.max).")
print("The minimum Int value is \(Int.min).")
print("The maximum value for a 32-bit integer is \(Int32.max).")
print("The minimum value for a 32-bit integer is \(Int32.max).")

print("The maximum UInt value is \(UInt.max)")
print("The minimum UInt value is \(UInt.min)")
print("The maximum value for a 32-bit unsigned integer is \(UInt32.max).")
print("The minimum value for a 32-bit unsigned integer is \(UInt32.min).")

let numberOfPages: Int = 10
let numberOfChapters = 3

let numberOfPeople: UInt = 40
let volumeAdjustment: Int32 = -1000

print(10 + 20)
print(30 - 5)
print(5 * 6)

print(11 / 3)
print(11 % 3)
print(-11 % 3)

let y: Int8 = 120
let z = y &+ 10
print("120 &+ 10 is \(z)")

let a: Int16 = 200
let b: Int8 = 50
let c = a + Int16(b)
