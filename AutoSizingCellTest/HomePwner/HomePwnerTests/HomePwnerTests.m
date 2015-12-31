//
//  HomePwnerTests.m
//  HomePwnerTests
//
//  Created by Hanguang on 12/31/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "BNRRACTestViewController.h"

@interface HomePwnerTests : XCTestCase
@property (nonatomic, strong) BNRRACTestViewController *test;
@end

@implementation HomePwnerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _test = [BNRRACTestViewController new];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
