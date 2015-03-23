//
//  LHStack.m
//  LHStack
//
//  Created by Hanguang on 3/23/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "LHStack.h"
@interface LHStack ()
@property (nonatomic, strong) NSMutableArray *numbers;

@end

@implementation LHStack

- (instancetype)init {
    if (self == [super init]) {
        _numbers = [NSMutableArray new];
    }
    return self;
}

- (void)push:(double)num {
    [self.numbers addObject:@(num)];
}

- (double)top {
    return [[self.numbers lastObject] doubleValue];
}

- (NSUInteger)count {
    return self.numbers.count;
}

- (double)pop {
    if ([self count] == 0) {
        [NSException raise:@"LHStackPopEmptyException" format:@"Cannot pop an empty stack"];
    }
    double result = [self top];
    [self.numbers removeLastObject];
    return result;
}

@end
