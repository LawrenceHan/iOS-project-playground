//
//  main.swift
//  MonsterTown
//
//  Created by Hanguang on 3/1/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

var myTown = Town()
myTown.changePopulation(500)

let fredTheZombie = Zombie()
fredTheZombie.town = myTown
fredTheZombie.terrorizeTown()
fredTheZombie.changeName("Fred the Zombie", walksWithLimp: false)
fredTheZombie.town?.printTownDescription()