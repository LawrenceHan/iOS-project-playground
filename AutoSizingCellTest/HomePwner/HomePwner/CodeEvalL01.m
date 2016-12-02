//
//  CodeEvalL01.m
//  HomePwner
//
//  Created by Hanguang on 28/11/2016.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "CodeEvalL01.h"

@implementation CodeEvalL01

+ (NSArray *)doWithDivers:(NSArray *)divers {
//    NSArray *file = @[@3, @5, @7];
//    NSArray *numbers = @[@1, @2, @3, @4, @5, @6, @7,@8, @9, @13, @15, @17];
    __block NSInteger x = 0;
    __block NSInteger y = 0;
    __block NSInteger count = 0;
    
    [divers enumerateObjectsUsingBlock:^(NSNumber * _Nonnull diver, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            x = diver.integerValue;
        } else if (idx == 1) {
            y = diver.integerValue;
        } else {
            count = diver.integerValue;
        }
    }];
    
    NSMutableArray *numbers = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [numbers addObject:@(i + 1)];
    }

    for (int idx = 0; idx < count; idx++) {
        NSNumber *number = numbers[idx];
        if (number.integerValue % x == 0 && number.integerValue % y == 0) {
            numbers[idx] = @"FB";
        } else if (number.integerValue % x == 0) {
            numbers[idx] = @"F";
        } else if (number.integerValue % y == 0) {
            numbers[idx] = @"B";
        }
    }
    
    return [numbers copy];
}

@end
