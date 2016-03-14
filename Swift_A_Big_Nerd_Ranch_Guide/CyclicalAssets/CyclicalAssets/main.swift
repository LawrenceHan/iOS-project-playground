//
//  main.swift
//  CyclicalAssets
//
//  Created by Hanguang on 3/14/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

var bob: Person? = Person(name: "Bob")
print("created \(bob)")



var laptop: Asset? = Asset(name: "Shiny Laptop", value: 1500.0)
var hat: Asset? = Asset(name: "Cowboy hat", value: 175.0)
var backpack: Asset? = Asset(name: "Blue Backpack", value: 45.0)

bob?.takeOwnershipOfAsset(laptop!)
bob?.takeOwnershipOfAsset(hat!)

laptop = nil
hat = nil
backpack = nil


bob = nil
print("the bob variable is now \(bob)")