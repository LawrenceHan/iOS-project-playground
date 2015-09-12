//
//  BNRInteractiveAnimator.h
//  HomePwner
//
//  Created by Hanguang on 9/12/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRInteractiveAnimator : UIPercentDrivenInteractiveTransition

- (instancetype)initWithViewController:(UIViewController*)controller;
- (void)pinchGestureAction:(UIPinchGestureRecognizer*)gestureRecognizer;

@end
