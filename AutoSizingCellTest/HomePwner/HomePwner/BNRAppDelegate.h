//
//  BNRAppDelegate.h
//  HomePwner
//
//  Created by John Gallagher on 1/7/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Chartboost/Chartboost.h>

@interface BNRAppDelegate : UIResponder <UIApplicationDelegate, ChartboostDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
