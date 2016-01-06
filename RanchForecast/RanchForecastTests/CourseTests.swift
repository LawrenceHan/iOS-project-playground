//
//  CourseTests.swift
//  RanchForecast
//
//  Created by Hanguang on 1/3/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

import XCTest
import RanchForecast

class CourseTests: XCTestCase {
    func testCourseInitialization() {
        let course = Course(title: Constants.title,
            url: Constants.url, nextStartDate: Constants.date)
        XCTAssertEqual(course.title, Constants.title)
        XCTAssertEqual(course.url, Constants.url)
        XCTAssertEqual(course.nextStartDate, Constants.date)
    }
}
