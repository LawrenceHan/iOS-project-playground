//
//  BNRSegue.m
//  HomePwner
//
//  Created by Hanguang on 8/31/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRSegue.h"
#import "SpringAnimationOC.h"

@implementation BNRSegue

- (void)perform {
    UIViewController *source = self.sourceViewController;
    UIViewController *destination = self.destinationViewController;
    
    CGRect frame = source.view.frame;
    CGRect originalSourceRect = source.view.frame;
    frame.origin.y = frame.size.height;
    
    [SpringAnimationOC springWithCompletion:0.3 delay:0 animation:^{
        source.view.frame = frame;
    } completion:^(BOOL finished) {
        source.view.alpha = 0.0;
        destination.view.frame = frame;
        destination.view.alpha = 0.0;
        [[source.view superview] addSubview:destination.view];
        
        [SpringAnimationOC springWithCompletion:0.5 delay:0 animation:^{
            destination.view.frame = originalSourceRect;
            destination.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            [destination.view removeFromSuperview];
            source.view.alpha = 1.0;
            [source.navigationController pushViewController:destination animated:NO];
        }];
    }];
}

@end
