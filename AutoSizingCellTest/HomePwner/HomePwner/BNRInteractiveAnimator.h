//
//  BNRInteractiveAnimator.h
//  HomePwner
//
//  Created by Hanguang on 9/12/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRInteractiveAnimator : UIPercentDrivenInteractiveTransition

- (void)wireToViewController:(UIViewController*)viewController;

/**
 This property indicates whether an interactive transition is in progress.
 */
@property (nonatomic, assign) BOOL interactionInProgress;

@end
