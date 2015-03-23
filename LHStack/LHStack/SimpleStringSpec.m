//
//  SimpleStringSpec.m
//  LHStack
//
//  Created by Hanguang on 3/23/15.
//  Copyright 2015 Hanguang. All rights reserved.
//

#import <Kiwi/Kiwi.h>


SPEC_BEGIN(SimpleStringSpec)

describe(@"SimpleString", ^{
    context(@"when assigned to 'Hello World'", ^{
        NSString *greeting = @"Hello World";
        it(@"should exist", ^{
            [[greeting shouldNot] beNil];
        });
        
        it(@"should equal to 'Hello World'", ^{
            [[greeting should] equal:@"Hello World"];
        });
    });

});

SPEC_END
