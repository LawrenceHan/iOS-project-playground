//
//  MainWindowController.swift
//  OAuth2Test
//
//  Created by Hanguang on 1/14/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa
import ReactiveCocoa
import AFNetworkActivityLogger

class MainWindowController: NSWindowController {

    @IBOutlet var outputTextView: NSTextView!
    @IBOutlet weak var requestButton: NSButton!
    
    var networkLog: String = ""
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let notiSignal = NSNotificationCenter.defaultCenter().rac_addObserverForName("AFNetworkActivityLoggerNotification", object: nil)
        notiSignal.subscribeNext { (requestLog) -> Void in
            if requestLog is NSString && requestLog.length > 0 {
                self.appendLog(requestLog as! String)
            }
        }
    }
    
    func appendLog(requestLog: String) {
        // Break the string into lines
        networkLog = requestLog.stringByAppendingFormat("\n %@", requestLog)
    }
}
