//
//  MessageLayout.h
//  HomePwner
//
//  Created by Hanguang on 2/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageLayout : NSObject
@property (nonatomic, strong) NSString *message;

- (YYTextLayout *)layoutWithMessage:(NSString *)message;
@end
