//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

var bucketList = ["Climb Mt. Everest"]
var newItems = ["Fly hot air balloon to Fiji",
    "Watch the Lord of the Rings trilogy in one day",
    "Go on a walkabout",
    "Scuba dive in the Great Blue Hole",
    "Find a triple rainbow"]
bucketList += newItems

bucketList.removeAtIndex(2)
print(bucketList.count)
print(bucketList[0...2])
bucketList[2] += " in Australia"
bucketList[0] = "Climb Mt. Kilimanjaro"
bucketList.insert("Toboggan across Alaska", atIndex: 2)
bucketList

var myronsList = [
    "Climb Mt. Kilimanjaro",
    "Fly hot air balloon to Fiji",
    "Toboggan across Alaska",
    "Go on a walkabout in Australia",
    "Scuba dive in the Great Blue Hole",
    "Find a triple rainbow"]
let equal = (bucketList == myronsList)
let lunches = ["Cheeseburger",
    "Veggie Pizza",
    "Chicken Caesar Salad",
    "Black Bean Burrito",
    "Falafel wrap"]
var toDoList = ["Take out garbage", "Pay bills", "Cross of finished items"]
print(toDoList)
toDoList = toDoList.reverse()
print(toDoList)


