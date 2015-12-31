//
//  IsNotEmptyTransformer.swift
//  Chatter
//
//  Created by Hanguang on 12/12/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

@objc
class IsNotEmptyTransformer: NSValueTransformer {
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        if let message = value as? String {
            return !message.isEmpty
        }
        return nil
    }

}
