//
//  LHStackTests.m
//  LHStackTests
//
//  Created by Hanguang on 3/23/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LHStack.h"

@interface LHStackTests : XCTestCase

@end

@implementation LHStackTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    LHStack *stack = [LHStack new];
    [stack push:4.5];
    [stack push:3.5];
    [stack push:6.5];
    [stack push:2.5];
    double topNumber = [stack top];
    XCTAssertEqual(topNumber, 2.5, @"topNumber must equal to stack's top value");
    XCTAssertNotNil(stack, @"object must not be nil after init");
}


@end
