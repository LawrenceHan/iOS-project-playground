//
//  MainWindowController.swift
//  Dice
//
//  Created by Hanguang on 12/13/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    var configurationWindowController: ConfigurationWindowController?
    
    // MARK: - Actions
    @IBAction func showDieConfiguration(sender: AnyObject?) {
        if let window = window, let dieView = window.firstResponder as? DieView {
            // Create and configure the window controller to present as sheet:
            let windowController = ConfigurationWindowController()
            windowController.configuration = DieConfiguration(color: dieView.color, rolls: dieView.numberOfTimesToRoll)
            
            windowController.presentAsSheetOnWindow(window, completionHandler: { (configuration) -> (Void) in
                if let configuration = configuration{
                    dieView.color = configuration.color
                    dieView.numberOfTimesToRoll = configuration.rolls
                }
            })
            configurationWindowController = windowController
        }
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == Selector("showDieConfiguration:") {
            return window?.firstResponder is DieView
        }
        return super.validateMenuItem(menuItem)
    }
}
