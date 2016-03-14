//
//  Vampire.swift
//  MonsterTown
//
//  Created by Hanguang on 3/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

class Vampire: Monster {
    var vampireThralls = [Vampire]()
    
    override func terrorizeTown() {
        if town?.population > 0 {
            vampireThralls.append(Vampire())
            town?.changePopulation(-1)
        }
    }
}