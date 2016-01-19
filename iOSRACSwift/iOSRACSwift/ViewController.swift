//
//  ViewController.swift
//  iOSRACSwift
//
//  Created by Hanguang on 1/18/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginButton(sender: UIButton) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameTextField.rac_textSignal()
            .toSignalProducer()
            .skip(2)
            .filter { (text) -> Bool in
                let string = text as! String
                return string.characters.count > 3
            }.startWithNext { (text) -> () in
                print(text!)
        }
//        let searchStrings = nameTextField.rac_textSignal()
//            .toSignalProducer()
//            .map { text in text as! String }
//            .throttle(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
//        
//        let searchResult = searchStrings
//            .flatMap(.Latest) { (query: String) -> SignalProducer<(NSData, NSURLResponse), NSError> in
//                let URLRequest = NSURLRequest(URL: NSURL(string: "http://www.baidu.com")!)
//                return NSURLSession.sharedSession()
//                    .rac_dataWithRequest(URLRequest)
//                    .retry(2)
//                    .flatMapError { error in
//                        print("Error: \(error)")
//                        return SignalProducer.empty
//                }
//            }
//            .map { (data, URLResponse) -> String in
//                let string = String(data: data, encoding: NSUTF8StringEncoding)!
//                return string
//            }
//            .observeOn(UIScheduler())
//        
//        searchResult.startWithNext { (results) -> () in
//            print("Search results: \(results)")
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

