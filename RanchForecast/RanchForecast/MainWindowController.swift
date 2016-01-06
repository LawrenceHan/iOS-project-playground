//
//  MainWindowController.swift
//  RanchForecast
//
//  Created by Hanguang on 1/2/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet weak var scrollView: NSScrollView!
    
    
    let fetcher = ScheduleFetcher()
    dynamic var courses: [Course] = []
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    override var windowNibName: String! {
        return "MainWindowController"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        progressIndicator.startAnimation(nil)
        progressIndicator.displayIfNeeded()
        
        tableView.target = self
        tableView.doubleAction = Selector("openClass:")
        
        fetcher.fetchCoursesUsingCompletionHandler { (result) -> Void in
            switch result {
            case .Success(let courses):
                print("Got courses: \(courses)")
                self.courses = courses
            case .Failure(let error):
                print("Got error: \(error)")
                NSAlert(error: error).runModal()
                self.courses = []
            }
            self.progressIndicator.stopAnimation(nil)
            self.scrollView.hidden = false
        }
    }
    
    func openClass(sender: AnyObject!) {
        if let course = arrayController.selectedObjects.first as? Course {
            NSWorkspace.sharedWorkspace().openURL(course.url)
        }
    }
}
