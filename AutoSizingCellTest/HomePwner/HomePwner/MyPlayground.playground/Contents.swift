//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

struct Stringy {
    let content: String
    
    init(_ content: String) {
        self.content = content
    }
    
    func append(appendage: Stringy) -> Stringy {
        return Stringy(self.content + " " + appendage.content)
    }
    
    func printMe() {
        print(content)
    }
}

var greeting = Stringy("Hi")

greeting.append(Stringy("how"))
    .append(Stringy("are"))
    .append(Stringy("you?"))
    .printMe()

func appendFreeFunction(a: Stringy, b: Stringy) -> Stringy {
    return Stringy(a.content + " " + b.content)
}

func printMe(a: Stringy) {
    a.printMe()
}

func appendCurriedFreeFunction(a: Stringy)(b: Stringy) -> Stringy {
    return Stringy(b.content + " " + a.content)
}

infix operator |> { associativity left }

func |><X> (stringy: Stringy, transform: Stringy -> X) -> X {
    return transform(stringy)
}

greeting
|> appendCurriedFreeFunction(Stringy("how"))
|> appendCurriedFreeFunction(Stringy("are"))
|> appendCurriedFreeFunction(Stringy("you?"))
|> printMe

