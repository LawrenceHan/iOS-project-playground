//
//  LHStackSpec.m
//  LHStack
//
//  Created by Hanguang on 3/23/15.
//  Copyright 2015 Hanguang. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "LHStack.h"


SPEC_BEGIN(LHStackSpec)

describe(@"LHStack", ^{
    context(@"when created", ^{
        __block LHStack *stack = nil;
        
        beforeEach(^{
            stack = [LHStack new];
        });
       
        afterEach(^{
            stack = nil;
        });
        
        it(@"should have the class LHStack", ^{
            [[[LHStack class] shouldNot] beNil];
        });
        
        it(@"should exist", ^{
            [[stack shouldNot] beNil];
        });
        
        it(@"should be able to push and get top value", ^{
            [stack push:2.5];
            [[theValue([stack top]) should] equal:theValue(2.5)];
            
            [stack push:4.5];
            [[theValue([stack top]) should] equal:4.5 withDelta:0.001];
            
        });
        
        it(@"should contain 0 element", ^{
            [[stack should] haveCountOf:0];
            [[stack should] beEmpty];
        });
        
        it(@"should raise an exception when pop", ^{
            [[theBlock(^{
                [stack pop];
            }) should] raiseWithName:@"LHStackPopEmptyException"];
        });
        
    });
    
    context(@"when new created and pushed 4.5", ^{
        __block LHStack *stack = nil;
        beforeEach(^{
            stack = [LHStack new];
            [stack push:4.5];
        });
        
        afterEach(^{
            stack = nil;
        });
        
        it(@"can be poped and the value equals 4.5", ^{
            [[theValue([stack top]) should] equal:theValue(4.5)];
        });
        
        it(@"should contains 0 element after pop", ^{
            [stack pop];
            [[stack should] beEmpty];
        });
        
    });
    
    
});

SPEC_END
