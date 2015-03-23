//
//  LHStack.h
//  LHStack
//
//  Created by Hanguang on 3/23/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHStack : NSObject

- (void)push:(double)num;
- (double)top;
- (NSUInteger)count;
- (double)pop;

@end
