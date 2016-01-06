//
//  Course.swift
//  RanchForecast
//
//  Created by Hanguang on 1/2/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import Foundation

public class Course: NSObject {
    public let title: String
    public let url: NSURL
    public let nextStartDate: NSDate
    
    public init(title: String, url: NSURL, nextStartDate: NSDate) {
        self.title = title
        self.url = url
        self.nextStartDate = nextStartDate
        super.init()
    }
    
}