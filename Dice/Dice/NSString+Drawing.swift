//
//  NSString+Drawing.swift
//  Dice
//
//  Created by Hanguang on 12/14/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

extension NSString {
    
    func drawCenteredInRect(rect: NSRect, attributes: [String: AnyObject]?) {
        let stringSize = sizeWithAttributes(attributes)
        let point = NSPoint(x: rect.origin.x + (rect.width - stringSize.width)/2.0,
            y: rect.origin.y + (rect.height - stringSize.height)/2.0)
        drawAtPoint(point, withAttributes: attributes)
    }
}
