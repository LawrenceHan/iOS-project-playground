//
//  main.swift
//  MonsterTown
//
//  Created by Hanguang on 3/1/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

var myTown = Town(region: "West", population: 0, stoplights: 6)
myTown?.printTownDescription()

let ts = myTown?.townSize
print(ts)

myTown?.changePopulation(100000)
print("Size: \(myTown?.townSize); population: \(myTown?.population)")

var fredTheZombie: Zombie? = Zombie(limp: false, fallingApart: false, town: myTown, monsterName: "Fred")
fredTheZombie?.terrorizeTown()
fredTheZombie?.changeName("Fred the Zombie", walksWithLimp: false)

var convenientZombie = Zombie(limp: true, fallingApart: false)

fredTheZombie?.town?.printTownDescription()

print("Victim pool: \(fredTheZombie?.victimPool)")
fredTheZombie?.victimPool = 500
print("Victim pool: \(fredTheZombie?.victimPool)")

print(Zombie.spookyNoise)
if Zombie.isTeerifying {
    print("Run away!")
}
fredTheZombie = nil