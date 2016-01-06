//
//  Constants.swift
//  RanchForecast
//
//  Created by Hanguang on 1/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

class Constants {
    static let urlString = "http://training.bignerdranch.com/classes/test-course"
    static let url = NSURL(string: urlString)!
    static let title = "Test Course"
    
    static let dateString = "2014-06-02"
    static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let date = dateFormatter.dateFromString(dateString)!
    
    static let validCourseDict = ["title" : title, "url" : urlString,
        "upcoming" : [["start_date" : dateString]]]
    
    static let coursesDictionary = ["courses" : [validCourseDict]]
    static let okResponse = NSHTTPURLResponse(URL: url, statusCode: 200, HTTPVersion: nil, headerFields: nil)
    
    static let jsonData = try! NSJSONSerialization.dataWithJSONObject(coursesDictionary, options: [])
}