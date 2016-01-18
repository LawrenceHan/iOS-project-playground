//
//  MainWindowController.swift
//  OAuth2Demo
//
//  Created by Hanguang on 1/15/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa
import ReactiveCocoa

class MainWindowController: NSWindowController {

    
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var authButton: NSButton!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSTextField!
    
    dynamic var username: String = ""
    dynamic var password: String = ""
    dynamic var networkLog: NSAttributedString = NSAttributedString(string: "")
    
    let manager = AuthenticationManager()
    
    override var windowNibName: String {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let notiSignal = NSNotificationCenter.defaultCenter().rac_addObserverForName("AFNetworkActivityLoggerNotification", object: nil)
        notiSignal.subscribeNext { (notification) -> Void in
            if notification != nil {
                let requestLog = notification.object
                self.appendLog(requestLog as! String)
            }
        }
    }
    
    @IBAction func requestForOAuth(sender: NSButton) {
        manager.requestOAuthWithSuccess({ (cred) -> Void in
            self.manager.requestOAuthWith(self.username,
                password: self.password,
                success: { (op, responseObject) -> Void in
                    print("Success!")
                }, failure: { (op, error) -> Void in
                    print("Failed!")
            })
            }) { (error) -> Void in
                print("Failed!")
        }
    }
    
    @IBAction func getMyProfile(sender: NSButton) {
        manager.getMyProfile()
    }
    
    func appendLog(requestLog: String) {
        // Break the string into lines
        if networkLog.length > 0 {
            var text = networkLog.string
            text = text.stringByAppendingString("\n\(requestLog)")
            networkLog = NSAttributedString(string: text)
        } else {
            networkLog = NSAttributedString(string: requestLog)
        }
    }
    
}
