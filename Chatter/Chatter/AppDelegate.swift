//
//  AppDelegate.swift
//  Chatter
//
//  Created by Hanguang on 12/11/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var windowControllers: [ChatWindowController] = []

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        addWindowController()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: Selector("receiveDidResignActiveNotification:"),
            name: NSApplicationDidResignActiveNotification, object: nil)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    
    // MARK: - Actions
    @IBAction func displayNewWindow(sender: NSMenuItem) {
        addWindowController()
    }
    
    // MARK: - Helpers
    func addWindowController() {
        let windowController = ChatWindowController()
        windowController.showWindow(self)
        windowControllers.append(windowController)
    }
    
    func receiveDidResignActiveNotification(note: NSNotification) {
        NSBeep()
    }
}

