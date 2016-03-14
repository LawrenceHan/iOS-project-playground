//
//  Accountant.swift
//  CyclicalAssets
//
//  Created by Hanguang on 3/14/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

class Accountant {
    typealias NetWorthChanged = (Double) -> ()
    
    var netWorthChangedHandler: NetWorthChanged? = nil
    var netWorth: Double = 0.0 {
        didSet {
            netWorthChangedHandler?(netWorth)
        }
    }
    
    func gainedNewAsset(asset: Asset) {
        netWorth += asset.value
    }
}