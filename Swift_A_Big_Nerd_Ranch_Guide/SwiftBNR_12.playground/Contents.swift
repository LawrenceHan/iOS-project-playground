//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

func printGreeting() {
    print("Hello World")
}
printGreeting()

func printPersonalGreeting(names: String...) {
    for name in names {
        print("Hello \(name), welcome to your playground.")
    }
}

printPersonalGreeting("Matt", "Chris", "Drew", "Pat")

func divisionDescription(forNumerator num: Double,
    andDenominator den: Double, punctunation: String = ".") -> String {
        return "\(num) divided by \(den) equals \(num / den)\(punctunation)"
}
divisionDescription(forNumerator: 9, andDenominator: 3)
divisionDescription(forNumerator: 12, andDenominator: 3, punctunation: "!")
print(divisionDescription(forNumerator: 100, andDenominator: 33))

var error = "The request failed:"
func appendErrorCode(code: Int, inout toErrorString errorString: String) {
    if code == 400 {
        errorString += " bad request."
    }
}
appendErrorCode(400, toErrorString: &error)
error

func areaOfTriangle(withBase base: Double, andHeight height: Double) -> Double {
    let numerator = base * height
    func divide() -> Double {
        return numerator / 2
    }
    return divide()
}
areaOfTriangle(withBase: 3, andHeight: 5)

func sortEvenOdd(numbers: [Int]) -> (evens: [Int], odds: [Int]) {
    var evens = [Int]()
    var odds = [Int]()
    for number in numbers {
        if number % 2 == 0 {
            evens.append(number)
        } else {
            odds.append(number)
        }
    }
    return (evens, odds)
}

let aBunchOfNumbers = [10,1,4,3,57,43,84,27,156,111]
let theSortedNumbers = sortEvenOdd(aBunchOfNumbers)
print("The even numbers are: \(theSortedNumbers.evens); the odd numbers are: \(theSortedNumbers.odds)")

func grabMiddleName(name: (String, String?, String)) -> String? {
    return name.1
}

let middleName = grabMiddleName(("Matt", nil, "Mathias"))
if let theName = middleName {
    print(theName)
}

func greetByMiddleName(name: (first: String, middle: String?, last: String)) {
    guard let middleName = name.middle where name.middle?.characters.count <= 4
        else {
            print("Hey there")
            return;
    }
    print("Hey \(middleName)")
}
greetByMiddleName(("Matt", "Danger", "Mathias"))

let groceryList = ["green beans", "milk", "black beans", "pinto beans", "apples"]
func beanSifter(groceryList list: [String]) -> (beans: [String], otherGroceries: [String]) {
    var beans = [String]()
    var otherGroceries = [String]()
    for fruit in list {
        if fruit.hasSuffix("beans") {
            beans.append(fruit)
        } else {
            otherGroceries.append(fruit)
        }
    }
    return (beans, otherGroceries)
}

let result = beanSifter(groceryList: groceryList)
print(result.beans)
print(result.otherGroceries)
