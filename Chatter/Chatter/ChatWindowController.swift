//
//  ChatWindowController.swift
//  Chatter
//
//  Created by Hanguang on 12/11/15.
//  Copyright © 2015 Hanguang. All rights reserved.
//

private let ChatWindowControllerDidSendMessageNotification = "com.bignerdranch.chatter.ChatwindowControllerDidSendMessageNotification"
private let ChatWindowControllerMessageKey = "com.bignerdranch.chatter.ChatWindowControllerMessageKey"

import Cocoa

class ChatWindowController: NSWindowController {

    dynamic var log: NSAttributedString = NSAttributedString(string: "")
    dynamic var message: String?
    dynamic var username: String?
    let randomNumber = arc4random_uniform(1000)
    
    // NSTextView does not support weak references.
    @IBOutlet var textView: NSTextView!
    
    // MARK: - Lifecycle
    override var windowNibName: String {
        return "ChatWindowController"
    }
    
    override init(window: NSWindow?) {
        NSValueTransformer.setValueTransformer(IsNotEmptyTransformer(), forName: "IsNotEmptyTransformer")
        super.init(window: window)
    }
    
    required init?(coder: NSCoder) {
        NSValueTransformer.setValueTransformer(IsNotEmptyTransformer(), forName: "IsNotEmptyTransformer")
        super.init(coder: coder)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: Selector("receiveDidSendMessageNotification:"),
            name: ChatWindowControllerDidSendMessageNotification,
            object: nil)
    }
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
    // MARK: - Actions
    @IBAction func send(sender: NSButton) {
        sender.window?.endEditingFor(nil)
        if var message = message {
            var defaultName = "unknown_\(randomNumber):"
            if let name = username {
                defaultName = "\(name)_\(randomNumber):"
            }
            
            message = defaultName + message
            
            let userInfo = [ChatWindowControllerMessageKey : message]
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(ChatWindowControllerDidSendMessageNotification,
                object: self,
                userInfo: userInfo)
        }
        message = ""
    }
    
    // MARK: - Notifications
    
    // ChatWindowControllerDidSendMessageNotification
    func receiveDidSendMessageNotification(note: NSNotification) {
        let mutableLog = log.mutableCopy() as! NSMutableAttributedString
        
        if log.length > 0 {
            mutableLog.appendAttributedString(NSAttributedString(string: "\n"))
        }
        
        let userInfo = note.userInfo! as! [String : String]
        let message = userInfo[ChatWindowControllerMessageKey]!
        
        var attributes = [String : NSColor]()
        if note.object! as! NSWindowController == self {
            attributes = [NSForegroundColorAttributeName : NSColor.blueColor()]
        } else {
            attributes = [NSForegroundColorAttributeName : NSColor.blackColor()]
        }
        
        let logLine = NSAttributedString(string: message, attributes: attributes)
        mutableLog.appendAttributedString(logLine)
        
        log = mutableLog.copy() as! NSAttributedString
        
        textView.scrollRangeToVisible(NSRange(location: log.length, length: 0))
    }
    
}
