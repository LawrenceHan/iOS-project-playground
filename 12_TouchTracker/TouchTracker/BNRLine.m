//
//  BNRLine.m
//  TouchTracker
//
//  Created by Hanguang on 14-6-5.
//  Copyright (c) 2014年 Big Nerd Ranch. All rights reserved.
//

#import "BNRLine.h"

@implementation BNRLine

- (CGFloat)angle {
    return atan((self.end.y - self.begin.y) / (self.end.x - self.begin.x));
}

- (UIColor *)lineColor {
    return [UIColor colorWithRed:0.3 green:fabs(self.angle) blue:0.5 alpha:1];
}

@end
