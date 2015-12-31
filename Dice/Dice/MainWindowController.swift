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
            
            window.beginSheet(windowController.window!, completionHandler: { (response) -> Void in
                // The sheet has finished. Did the user click 'OK'?
                if response == NSModalResponseOK {
                    let configuration = self.configurationWindowController!.configuration
                    
                    dieView.color = configuration.color
                    dieView.numberOfTimesToRoll = configuration.rolls
                }
                // All done with window controller.
                self.configurationWindowController = nil
            })
            configurationWindowController = windowController
        }
    }
}
