//
//  BNRLine.h
//  TouchTracker
//
//  Created by Hanguang on 14-6-5.
//  Copyright (c) 2014年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRLine : NSObject

@property (nonatomic) CGPoint begin;
@property (nonatomic) CGPoint end;
@property (nonatomic, readonly) UIColor *lineColor;
@property (nonatomic, readonly) CGFloat angle;

@end
