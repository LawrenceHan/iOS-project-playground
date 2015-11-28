/*
 * ViewController.h
 * ChartboostExampleApp
 *
 * Copyright (c) 2013 Chartboost. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import <Chartboost/CBInPlay.h>

@interface ViewController : UIViewController

@property (nonatomic, readwrite) BOOL inPlayShowing;
@property (nonatomic, readwrite) BOOL piaShowing;
@property (nonatomic, readwrite) BOOL inPlayShowingError;

- (IBAction)showInterstitial;

- (IBAction)showMoreApps;

- (IBAction)showRewardedVideo;

- (IBAction)showSupport:(id)sender;

- (IBAction)showInPlay:(id)sender;

- (IBAction)sendPIALevelTracking:(id)sender;

- (void)renderInPlay:(CBInPlay*)inPlay;

- (void)renderInPlayError:(NSString*)error;
    
@end
