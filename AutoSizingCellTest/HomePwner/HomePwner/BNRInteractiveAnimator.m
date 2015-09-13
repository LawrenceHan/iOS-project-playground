//
//  BNRInteractiveAnimator.m
//  HomePwner
//
//  Created by Hanguang on 9/12/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRInteractiveAnimator.h"

@implementation BNRInteractiveAnimator {
    BOOL _shouldCompleteTransition;
    UIViewController *_viewController;
    UIPinchGestureRecognizer *_gesture;
    CGFloat _startScale;
}

-(void)dealloc {
    [_gesture.view removeGestureRecognizer:_gesture];
}

- (void)wireToViewController:(UIViewController *)viewController {
    _viewController = viewController;
    [self prepareGestureRecognizerInView:viewController.view];
}

- (void)prepareGestureRecognizerInView:(UIView*)view {
    UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [view addGestureRecognizer:gesture];
}

- (CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}

- (void)handleGesture:(UIPinchGestureRecognizer*)gestureRecognizer {
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _startScale = gestureRecognizer.scale;
            
            // start an interactive transition!
            self.interactionInProgress = YES;
            
            // perform the required operation
                [_viewController dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged: {
            // compute the current pinch fraction
            CGFloat fraction = 1.0 - gestureRecognizer.scale / _startScale;
            _shouldCompleteTransition = (fraction > 0.5);
            [self updateInteractiveTransition:fraction];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.interactionInProgress = NO;
            if (!_shouldCompleteTransition || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            }
            else {
                [self finishInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

@end
