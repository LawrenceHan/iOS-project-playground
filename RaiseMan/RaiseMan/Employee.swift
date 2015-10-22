//
//  Employee.swift
//  RaiseMan
//
//  Created by Hanguang on 9/28/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Foundation

class Employee: NSObject, NSCoding {
    var name: String? = "New Employee"
    var raise: Float = 0.05
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String?
        raise = aDecoder.decodeFloatForKey("raise")
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let name = name {
            aCoder.encodeObject(name, forKey: "name")
        }
        aCoder.encodeFloat(raise, forKey: "raise")
    }
    
    override init() {
        super.init()
    }
    
    // MARK: Validatation delegate
    func validateRaise(raiseNumberPointer: AutoreleasingUnsafeMutablePointer<NSNumber?>) throws {
            let raiseNumber = raiseNumberPointer.memory
            if raiseNumber == nil {
                let domain = "UserInputValidationErrorDomain"
                let code = 0
                let userInfo = [NSLocalizedDescriptionKey : "An employee's raise must be a number."]
                throw NSError(domain: domain, code: code, userInfo: userInfo)
            }
    }
}

