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

let d1 = 1.1
let d2: Double = 1.1
let f1: Float = 100.3

print(10.0 + 11.4)
print(11.0 / 3.0)
print(12.4 % 5.0)

if d1 == d2 {
    print("d1 and d2 are the same!")
}

print("d1 + 0.1 is \(d1 + 0.1)")
if d1 + 0.1 == 1.2 {
    print("d1 +0.1 is equal to 1.2")
}

let u: UInt8 = 255
let uu = u &+ 1

// MARK: - Charpter 5 Switch

var statusCode: Int = 418
var errorString: String

switch statusCode {
case 400:
    errorString = "Bad request"
case 401:
    errorString = "Unauthorized"
case 403:
    errorString = "Forbidden"
case 404:
    errorString = "Not found"
default:
    errorString = "None"
}

switch statusCode {
case 400, 401, 403, 404:
    errorString = "There was something wrong with the rqeuest"
    fallthrough
default:
    errorString += " Please review the request and try again"
}

switch statusCode {
case 100, 101:
    errorString += " Informational, \(statusCode)"
case 204:
    errorString += " Successful but no content, \(statusCode)"
case 300...307:
    errorString += " Redirection, \(statusCode)"
case let unknownCode where (unknownCode >= 200 && unknownCode < 300) || unknownCode > 505:
    errorString = "\(unknownCode) is not a known error code."
default:
    errorString = "Unexpected error encountered."
}

let error = (statusCode, errorString)
error.0
error.1



