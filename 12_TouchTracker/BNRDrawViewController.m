//
//  BNRDrawViewController.m
//  TouchTracker
//
//  Created by Hanguang on 14-6-5.
//  Copyright (c) 2014年 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawViewController.h"
#import "BNRDrawView.h"

@interface BNRDrawViewController ()


@end

@implementation BNRDrawViewController

- (void)loadView
{
    self.view = [[BNRDrawView alloc] initWithFrame:CGRectZero];
}

@end
