//
//  Town.swift
//  MonsterTown
//
//  Created by Hanguang on 3/1/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

struct Town {
    static let region = "South"
    var population = 5422 {
        didSet(oldPopulation) {
            if population < oldPopulation {
                print("The population has changed to \(population) from \(oldPopulation)")
            } else {
                mayor.saySomething()
            }
        }
    }
    var numberOfStoplights = 4
    
    enum Size {
        case Small
        case Medium
        case Large
    }
    
    var townSize: Size {
        get {
            switch self.population {
            case 0...10000:
                return Size.Small
                
            case 10001...100000:
                return Size.Medium
                
            default:
                return Size.Large
            }
        }
    }
    
    var mayor = Mayor()
    
    func printTownDescription() {
        print("Population: \(myTown.population), number of stoplights: \(myTown.numberOfStoplights)")
    }
    
    mutating func changePopulation(amount: Int) {
        population += amount
        if population < 0 {
            population = 0
        }
    }
}