//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

var volunteerCounts = [1,3,40,32,2,53,77,13]

let volunteersSorted = volunteerCounts.sort { $0 < $1 }

func makeTownGrand(budget: Int, condition: Int -> Bool) -> ((Int, Int) -> Int)? {
    if condition(budget) {
        func buildRoads(lightsToAdd: Int, toLights: Int) -> Int {
            return toLights + lightsToAdd
        }
        return buildRoads
    } else {
        return nil
    }
}
func evalunateBudget(budget: Int) -> Bool {
    return budget > 10000
}

var stoplights = 4

if let townPlan = makeTownGrand(1000, condition: evalunateBudget) {
    stoplights = townPlan(4, stoplights)
}
print("Knowhere has \(stoplights) stoplights.")

func makeGrowthTracker(forGrowth growth: Int) -> () -> Int {
    var totalGrowth = 0
    func growthTracker() -> Int {
        totalGrowth += growth
        return totalGrowth
    }
    return growthTracker
}
var currentPopulation = 5422
let growBy500 = makeGrowthTracker(forGrowth: 500)
growBy500()
growBy500()
growBy500()
currentPopulation += growBy500()
let anotherGrowBy500 = growBy500
anotherGrowBy500()
var someOtherPopulation = 4061981
let growBy10000 = makeGrowthTracker(forGrowth: 10000)
someOtherPopulation += growBy10000()
currentPopulation

let precinctPopulations = [1244, 2021, 2157]
let projectedPopulations = precinctPopulations.map { $0 * 2 }
projectedPopulations

let bigProjections = projectedPopulations.filter { $0 > 4000 }
bigProjections

let totalProjection = projectedPopulations.reduce(0) { $0 + $1 }
totalProjection

let array = [1, 1234, 4, 12, 66, 11, 123]
let result = array.reduce(0) { $0 + $1 }
print(result)


