//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
var groceryBag: Set = ["Apples", "Oranges", "Pineapple"]

for food in groceryBag {
    print(food)
}

let hasBananas = groceryBag.contains("Bananas")
let friendsGroceryBag = Set(["Bananas", "Cereal", "Milk", "Oranges"])
var commonGroceryBag = groceryBag.union(friendsGroceryBag)

let roommatesGroceryBag = Set(["Apples", "Bananas", "Cereal", "Toothpaste"])
let itemsToReturn = commonGroceryBag.intersect(roommatesGroceryBag)

let yourSecondBag = Set(["Berries", "Yogurt"])
let roommatesSecondBag = Set(["Grapes", "Honey"])
let disjoint = yourSecondBag.isDisjointWith(roommatesGroceryBag)

let myCities = Set(["Atlanta", "Chicago", "Jacksonville", "New York", "San Francisco"])
let yourCities = Set(["Chicago", "San Francisco", "Jacksonville"])

let isSuperSet = myCities.isSupersetOf(yourCities)
let isStrictSuperSet = myCities.isStrictSupersetOf(yourCities)

groceryBag.unionInPlace(friendsGroceryBag)
commonGroceryBag.intersectInPlace(roommatesGroceryBag)

print(groceryBag)
print(commonGroceryBag)