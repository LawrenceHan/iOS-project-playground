//
//  ConfigurationWindowController.swift
//  Dice
//
//  Created by Hanguang on 12/29/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//


import Cocoa

struct DieConfiguration {
    let color: NSColor
    let rolls: Int
    
    init(color: NSColor, rolls: Int) {
        self.color = color
        self.rolls = max(rolls, 1)
    }
}

enum SheetResult: Int {
    case Accept
    case Cancel
}

class ConfigurationWindowController: NSWindowController {
    
    var configuration: DieConfiguration {
        set {
            color = newValue.color
            rolls = newValue.rolls
        }
        get {
            return DieConfiguration(color: color, rolls: rolls)
        }
    }
    
    private dynamic var color: NSColor = NSColor.whiteColor()
    private dynamic var rolls: Int = 10
    
    override var windowNibName: String {
        return "ConfigurationWindowController"
    }
    
    func presentAsSheetOnWindow(presentingWindow: NSWindow, completionHandler:(DieConfiguration?) -> (Void)) {
        presentingWindow.beginSheet(window!) { (response) -> Void in
            if response == SheetResult.Accept.rawValue {
                completionHandler(self.configuration)
            }
        }
    }
    
    @IBAction func okayButtonClicked(button: NSButton) {
        print("OK clicked")
        window?.endEditingFor(nil)
        dismissWithModalResponse(SheetResult.Accept.rawValue)
    }
    
    @IBAction func cancelButtonClicked(button: NSButton) {
        print("Cancel clicked")
        dismissWithModalResponse(SheetResult.Cancel.rawValue)
    }
    
    func dismissWithModalResponse(response: NSModalResponse) {
        window!.sheetParent!.endSheet(window!, returnCode: response)
    }
}
