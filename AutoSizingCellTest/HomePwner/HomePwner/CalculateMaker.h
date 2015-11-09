//
//  CalculateMaker.h
//  HomePwner
//
//  Created by Hanguang on 11/8/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculateMaker : NSObject
@property (nonatomic) int result;

+ (int)cal_calculateMaker:(void(^)(CalculateMaker *maker))block;

- (CalculateMaker *(^)(int))add;
- (CalculateMaker *(^)(int))sub;
- (CalculateMaker *(^)(int))multi;
- (CalculateMaker *(^)(int))divide;

@end
