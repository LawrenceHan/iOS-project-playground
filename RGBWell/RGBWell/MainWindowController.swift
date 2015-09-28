//
//  MainWindowController.swift
//  RGBWell
//
//  Created by Hanguang on 9/22/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    dynamic var r = 0.0
    dynamic var g = 0.0
    dynamic var b = 0.0
    let a = 1.0
    
    private var privateColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 1)
    dynamic var wellColor: NSColor {
        set {
            let color = NSColor(calibratedRed: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
            print("Set Well color to: \(color)")
            privateColor = color
        }
        get {
            let color = NSColor(calibratedRed: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
            print("Get Well color")
            return color
        }
        
    }
    
    override var windowNibName: String? {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
    }
    
    class func keyPathsForValuesAffectingWellColor() -> Set<String> {
        return ["r", "g", "b"]
    }
 
    
}
