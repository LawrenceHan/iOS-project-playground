//
//  CalculateMaker.m
//  HomePwner
//
//  Created by Hanguang on 11/8/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import "CalculateMaker.h"

@implementation CalculateMaker

+ (int)cal_calculateMaker:(void(^)(CalculateMaker *maker))block {
    CalculateMaker *maker = [CalculateMaker new];
    maker.result = 0;
    block(maker);
    return maker.result;
}

- (CalculateMaker *(^)(int))add {
    return ^(int number){
        self.result += number;
        return self;
    };
}

- (CalculateMaker *(^)(int))sub {
    return ^(int number){
        self.result -= number;
        return self;
    };
}

- (CalculateMaker *(^)(int))multi {
    return ^(int number){
        self.result *= number;
        return self;
    };
}

- (CalculateMaker *(^)(int))divide {
    return ^(int number){
        self.result /= number;
        return self;
    };
}

@end
