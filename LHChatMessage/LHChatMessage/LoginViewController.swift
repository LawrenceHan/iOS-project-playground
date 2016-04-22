//
//  LoginViewController.swift
//  LHChatMessage
//
//  Created by Hanguang on 3/15/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button methods
    @IBAction func login(sender:AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(loginTextField.text!, forKey: "userID")
        NSUserDefaults.standardUserDefaults().setObject(passwordTextField.text!, forKey: "userPassword")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.connect { (connected) -> () in
            if connected {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: "Login failed", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
