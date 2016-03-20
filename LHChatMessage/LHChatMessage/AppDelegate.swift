//
//  AppDelegate.swift
//  LHChatMessage
//
//  Created by Hanguang on 3/15/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import UIKit
import XMPPFramework
import AFNetworking

protocol ChatDelegate {
    func buddyWentOnline(name: String)
    func buddyWentOffline(name: String)
    func didDisconnect()
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, XMPPRosterDelegate, XMPPStreamDelegate {
    
    var window: UIWindow?
    
    // XMPP
    var delegate: ChatDelegate! = nil
    let xmppStream = XMPPStream()
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster
    
    override init() {
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        // XMPP
        setupStream()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        disconnect()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        connect { _ in /* Do nothing */ }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MRAK: - Private methods
    private func setupStream() {
        xmppRoster.activate(xmppStream)
        xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    private func goOnline() {
        let presence = XMPPPresence()
        let domain = xmppStream.myJID.domain
        
        if domain == "gmail.com" || domain == "gtalk.com" || domain == "talk.google.com" {
            let priority = DDXMLElement.elementWithName("priority", stringValue: "24") as! DDXMLElement
            presence.addChild(priority)
        }
        xmppStream.sendElement(presence)
    }
    
    private func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.sendElement(presence)
    }
    
    func connect(completion: (Bool) -> ()) {
        if !xmppStream.isConnected() {
            if !xmppStream.isDisconnected() {
                completion(true)
                return
            }

            guard let jabberID = NSUserDefaults.standardUserDefaults().stringForKey("userID"),
                let _ = NSUserDefaults.standardUserDefaults().stringForKey("userPassword") else {
                    completion(false)
                    return
            }
            
            let baseURL = "http://integration.flirten.de/api_integration.php"
            let manager = AFHTTPSessionManager(baseURL: NSURL(string: baseURL))
            let paramerter = ["grant_type": "client_credentials", "scope": ""]
            
            
            
            manager.POST("v2/auth/access_token", parameters: paramerter,
                success: { (dataTask: NSURLSessionDataTask, responseObject: AnyObject?) -> Void in
                    
                    self.xmppStream.hostName = "xmpp.integration.flirten.de"
                    self.xmppStream.hostPort = 5223
                    
                    let accessToken = responseObject?.valueForKey("access_token")
                    NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: "userPassword")
                    let jID = jabberID + "xmpp.integration.flirten.de"
                    
                    self.xmppStream.myJID = XMPPJID.jidWithString(jID)
                    //            xmppStream.myJID = XMPPJID.jidWithString(jabberID)
                    
                    do {
                        try self.xmppStream.connectWithTimeout(XMPPStreamTimeoutNone)
                        print("Connection success")
                        completion(true)
                    } catch {
                        print("Something went wrong!")
                        completion(false)
                    }
                    
                }, failure: { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
                    print("dataTask: \(dataTask), error: \(error)")
                    completion(false)
            })
        } else {
            completion(true)
        }
    }
    
    func disconnect() {
        goOffline()
        xmppStream.disconnect()
    }
    
    // MARK: XMPP Delegates
    func xmppStreamDidConnect(sender: XMPPStream!) {
        do {
            try xmppStream.authenticateWithPassword(NSUserDefaults.standardUserDefaults().stringForKey("userPassword"))
        } catch {
            print("Could not authenticate")
        }
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        print("Did receive message \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("Did send message \(message)")
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type()
        let myUsername = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != myUsername {
            print("Did receive presence from \(presenceFromUser)")
            if presenceType == "available" {
                delegate.buddyWentOnline("\(presenceFromUser)@gmail.com")
            } else if presenceType == "unavailable" {
                delegate.buddyWentOffline("\(presenceFromUser)@gmail.com")
            }
        }
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        print("Did receive Roster item")
    }
    
}

/*
func connect() -> Bool {
if !xmppStream.isConnected() {
let jabberID = NSUserDefaults.standardUserDefaults().stringForKey("userID")
var myPassword = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")

if !xmppStream.isDisconnected() {
return true
}
if jabberID == nil && myPassword == nil {
return false
}

let baseURL = "http://integration.flirten.de/api_integration.php"
let manager = AFHTTPSessionManager(baseURL: NSURL(string: baseURL))
let paramerter = ["grant_type": "client_credentials", "scope": ""]

var connected = false

[manager .POST("v2/auth/access_token", parameters: paramerter,
success: { (dataTask: NSURLSessionDataTask, object: AnyObject?) -> Void in


self.xmppStream.hostName = "xmpp.flirten.lab"
self.xmppStream.hostPort = 5222

myPassword = "b8ff369bf32fb046d20604238486b57fa84f8860"
self.xmppStream.myJID = XMPPJID.jidWithString("195677@xmpp.flirten.lab")
//            xmppStream.myJID = XMPPJID.jidWithString(jabberID)

do {
try self.xmppStream.connectWithTimeout(XMPPStreamTimeoutNone)
print("Connection success")
connected = true
} catch {
print("Something went wrong!")
connected = false
}

}, failure: { (dataTask: NSURLSessionDataTask?, error: NSError) -> Void in
print("dataTask: \(dataTask), error: \(error)")
})]
return connected
} else {
return true
}
}
*/