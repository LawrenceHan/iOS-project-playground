//
//  CarArrayController.swift
//  CarLot
//
//  Created by Hanguang on 11/20/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class CarArrayController: NSArrayController {
    override func newObject() -> AnyObject {
        let newObj = super.newObject() as! NSObject
        let now = NSDate()
        newObj.setValue(now, forKey: "datePurchased")
        return newObj
    }
}
