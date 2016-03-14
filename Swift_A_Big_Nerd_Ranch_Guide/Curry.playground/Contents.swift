//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

func greetName(name: String, withGreeting greeting: String) -> String {
    return "\(greeting) \(name)"
}

let personalGreeting = greetName("Matt", withGreeting: "Hello,")
print(personalGreeting)

func greetingForName(name: String) -> (String) -> String {
    func greeting(greeting: String) -> String {
        return "\(greeting) \(name)"
    }
    return greeting
}

let greeterFunction = greetingForName("Matt")
let theGreeting = greeterFunction("Hello,")

func greeting(greeting: String)(name: String)(number: Int) -> String {
    return "\(greeting) \(name) this is \(number) time"
}

let friendlyGreeting = greeting("Hello,")
let newGreeting = friendlyGreeting(name: "Matt")
let finally = newGreeting(number: 20)


struct Person {
    var firstName = "Matt"
    var lastName = "Mathias"
    
    mutating func changeName(fn: String, ln: String) {
        firstName = fn
        lastName = ln
    }
}
var p = Person()
p.changeName("John", ln: "Gallagher")
p.firstName

