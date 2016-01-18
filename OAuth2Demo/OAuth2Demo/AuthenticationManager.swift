//
//  AuthenticationManager.swift
//  OAuth2Test
//
//  Created by Hanguang on 1/15/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa
import AFNetworking
import ReactiveCocoa

class AuthenticationManager {
    let baseURL = "http://integration.flirten.de/api_integration.php/"
    let oauthURL = "v2/auth/access_token"
    let clientID = "flirten"
    let secret = "secret"
    let scope = ""
    let serviceProviderIdentifier = "com.ideawise.koko"
    
    // MARK: - API URL
    let myProfileURL = "v2/account/me"
    
    var credential: AFOAuthCredential {
        get {
            return AFOAuthCredential.retrieveCredentialWithIdentifier(serviceProviderIdentifier)
        }
    }
    
    let oauthManager: AFOAuth2Manager
    let requestManager: AFHTTPRequestOperationManager
    
    
    init() {
        requestManager = AFHTTPRequestOperationManager(baseURL: NSURL(string: baseURL))
        oauthManager = AFOAuth2Manager(baseURL: NSURL(string: baseURL), clientID: clientID, secret: secret)
    }
    
    
    // MARK: - Request method
    func requestOAuthWithSuccess(success: (cred: AFOAuthCredential) -> Void,
        failure: (error: NSError) -> Void) {
            oauthManager.authenticateUsingOAuthWithURLString(oauthURL,
                scope: "",
                success: { (cred) -> Void in
                    self.updateCredential(cred)
                    success(cred: cred)
                }) { (error) -> Void in
                    let log = "Error: \(error.localizedDescription)"
                    self.logWithString(log)
            }
    }
    
    func requestOAuthWith(username: String, password: String,
        success: (op: AFHTTPRequestOperation?, responseObject: AnyObject?) -> Void,
        failure: (op: AFHTTPRequestOperation?, error: NSError?) -> Void) {
            let parameters = ["client_id" : clientID,
                "client_secret" : secret,
                "grant_type" : "password",
                "username" : username,
                "password" : password]
            
            requestManager.POST(oauthURL,
                parameters: parameters,
                success: { (op, responseObject) -> Void in
                    let dict = responseObject as! Dictionary<String, AnyObject>
                    let accessToken = dict["access_token"] as! String
                    let refreshToken = dict["refresh_token"] as! String
                    let tokenType = dict["token_type"] as! String
                    // Expiration is optional, but recommended in the OAuth2 spec. It not provide, assume distantFuture === never expires
                    var expireDate = NSDate.distantFuture()
                    let expiresIn = dict["expires_in"] as? Double
                    if let expiresIn = expiresIn {
                        expireDate = NSDate.init(timeIntervalSinceNow: expiresIn)
                    }
                    
                    let cred = AFOAuthCredential.init(OAuthToken: accessToken, tokenType: tokenType)
                    cred.setExpiration(expireDate)
                    cred.setRefreshToken(refreshToken)
                    self.updateCredential(cred)
                    
                    let log = "ResponseObject: \(responseObject)"
                    self.logWithString(log)
                    
                    success(op: op, responseObject: responseObject)
                }) { (op, error) -> Void in
                    let log = ("Error: \(error.localizedDescription)")
                    self.logWithString(log)
                    failure(op: op, error: error)
            }
    }
    
    func refreshToken() {
        oauthManager.authenticateUsingOAuthWithURLString(oauthURL,
            refreshToken: credential.refreshToken,
            success: { (cred) -> Void in
                self.logWithString("Updated crendential: \(cred)")
                self.updateCredential(cred)
            }) { (error) -> Void in
                print("Error: \(error.localizedDescription)")
        }
    }
    
    func updateCredential(cred: AFOAuthCredential) {
        AFOAuthCredential.storeCredential(cred, withIdentifier: self.serviceProviderIdentifier)
        requestManager.requestSerializer.setAuthorizationHeaderFieldWithCredential(cred)
    }
    
    func requestGetWithPath(path: String, parameters: [String : AnyObject]) -> Signal<AFHTTPRequestOperation?, NSError> {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            let op = self.requestManager.GET(path, parameters: parameters,
                success: { (operation, responseObject) -> Void in
                    let tuple = RACTuple(objectsFromArray: [operation, responseObject])
                    subscriber.sendNext(tuple)
                    subscriber.sendCompleted()
                },
                failure: { (operation, error) -> Void in
                    subscriber.sendError(error)
            })
            
            return RACDisposable(block: { () -> Void in
                op?.cancel()
            })
        })
    }
    
    func requestPostWithPath(path: String, parameters: [String : AnyObject]) -> RACSignal {
        return RACSignal.createSignal({ (subscriber) -> RACDisposable! in
            let op = self.requestManager.POST(path, parameters: parameters,
                success: { (operation, responseObject) -> Void in
                    let tuple = RACTuple(objectsFromArray: [operation, responseObject])
                    subscriber.sendNext(tuple)
                    subscriber.sendCompleted()
                },
                failure: { (operation, error) -> Void in
                    subscriber.sendError(error)
            })
            
            return RACDisposable(block: { () -> Void in
                op?.cancel()
            })
        })
    }
    
    func refreshTokenIfNecessaryWithSignal(signal: RACSignal) -> RACSignal {
    }
    
    func getMyProfile() -> RACSignal {
        let requestSignal = requestGetWithPath(myProfileURL, parameters: [:])
        requestSignal.map { (tuple) -> AnyObject! in
            let response = tuple as! RACTuple
            let dict = response.second
            self.logWithString("Response object: \(dict)")
            return dict
        }
        
        return refreshTokenIfNecessaryWithSignal(requestSignal)
    }
    
    // MARK: - LOG
    func logWithString(log: String) {
        let notification = NSNotification(name: "AFNetworkActivityLoggerNotification", object: log)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}


