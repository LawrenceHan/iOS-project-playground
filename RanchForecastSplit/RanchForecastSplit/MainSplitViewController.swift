//
//  MainSplitViewController.swift
//  RanchForecastSplit
//
//  Created by Hanguang on 1/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Cocoa

class MainSplitViewController: NSSplitViewController, CourseListViewControllerDelegate {
    
    var masterViewController: CourseListViewController {
        return splitViewItems[0].viewController as! CourseListViewController
    }
    
    var detailViewController: WebViewController {
        return splitViewItems[1].viewController as! WebViewController
    }
    
    let defaultURL = NSURL(string: "http://www.bignerdranch.com/")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        masterViewController.delegate = self
        detailViewController.loadURL(defaultURL)
    }
    
    // MARK: - CourseListViewControllerDelegate
    func courseListViewController(viewController: CourseListViewController,
        selectedCourse: Course?) {
            if let course = selectedCourse {
                detailViewController.loadURL(course.url)
            }
            else {
                detailViewController.loadURL(defaultURL)
            }
    }
}
