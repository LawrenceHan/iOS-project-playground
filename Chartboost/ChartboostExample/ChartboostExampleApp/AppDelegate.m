/*
 * AppDelegate.m
 * ChartboostExampleApp
 *
 * Copyright (c) 2013 Chartboost. All rights reserved.
 */

#import <Chartboost/Chartboost.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

@interface AppDelegate () <ChartboostDelegate>
@end

@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Begin a user session. Must not be dependent on user actions or any prior network requests.
    [Chartboost startWithAppId:@"4f21c409cd1cb2fb7000001b" appSignature:@"92e2de2fd7070327bdeb54c15a5295309c6fcd2d" delegate:self];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Print IFA (Identifier for Advertising) in Output section. Add to applicationDidBecomeActive. iOS 6+ devices only.
    NSString* ifa = [[[NSClassFromString(@"ASIdentifierManager") sharedManager] advertisingIdentifier] UUIDString];
    
    if (ifa) {
    
        ifa = [[ifa stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
        NSLog(@"IFA: %@",ifa);
        
    }
    else {
        
         NSLog(@"IFA: No IFA returned from device");
    }
    
}

/*
 * Chartboost Delegate Methods
 *
 */

/*
 * didInitialize
 *
 * This is used to signal when Chartboost SDK has completed its initialization.
 *
 * status is YES if the server accepted the appID and appSignature as valid
 * status is NO if the network is unavailable or the appID/appSignature are invalid
 *
 * Is fired on:
 * -after startWithAppId has completed background initialization and is ready to display ads
 */
- (void)didInitialize:(BOOL)status {
    NSLog(@"didInitialize");
    // chartboost is ready
    [Chartboost cacheRewardedVideo:CBLocationMainMenu];
    [Chartboost cacheMoreApps:CBLocationHomeScreen];

    // Show an interstitial whenever the app starts up
    [Chartboost showInterstitial:CBLocationHomeScreen];
}


/*
 * shouldDisplayInterstitial
 *
 * This is used to control when an interstitial should or should not be displayed
 * The default is YES, and that will let an interstitial display as normal
 * If it's not okay to display an interstitial, return NO
 *
 * For example: during gameplay, return NO.
 *
 * Is fired on:
 * -Interstitial is loaded & ready to display
 */

- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    NSLog(@"about to display interstitial at location %@", location);

    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;
    
    // Otherwise return YES to display the interstitial
    return YES;
}


/*
 * didFailToLoadInterstitial
 *
 * This is called when an interstitial has failed to load. The error enum specifies
 * the reason of the failure
 */

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Interstitial, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Interstitial, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Interstitial, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Interstitial, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Interstitial, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Interstitial, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Interstitial, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Interstitial, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Interstitial, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Interstitial, unknown error !");
        }
    }
}

/*
 * didCacheInterstitial
 *
 * Passes in the location name that has successfully been cached.
 *
 * Is fired on:
 * - All assets loaded
 * - Triggered by cacheInterstitial
 *
 * Notes:
 * - Similar to this is: (BOOL)hasCachedInterstitial:(NSString *)location;
 * Which will return true if a cached interstitial exists for that location
 */

- (void)didCacheInterstitial:(NSString *)location {
    NSLog(@"interstitial cached at location %@", location);
}

/*
 * didFailToLoadMoreApps
 *
 * This is called when the more apps page has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No more apps page has been created (add a more apps page in the dashboard)
 * - No publishing campaign matches for that user (add more campaigns to your more apps page)
 *  -Find this inside the App > Edit page in the Chartboost dashboard
 */

- (void)didFailToLoadMoreApps:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load More Apps, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load More Apps, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load More Apps, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load More Apps, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load More Apps, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load More Apps, first session !");
        } break;
        case CBLoadErrorNoAdFound: {
            NSLog(@"Failed to load More Apps, Apps not found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load More Apps, session not started !");
        } break;
        default: {
            NSLog(@"Failed to load More Apps, unknown error !");
        }
    }
}

/*
 * didDismissInterstitial
 *
 * This is called when an interstitial is dismissed
 *
 * Is fired on:
 * - Interstitial click
 * - Interstitial close
 *
 */

- (void)didDismissInterstitial:(NSString *)location {
    NSLog(@"dismissed interstitial at location %@", location);
}

/*
 * didDismissMoreApps
 *
 * This is called when the more apps page is dismissed
 *
 * Is fired on:
 * - More Apps click
 * - More Apps close
 *
 */

- (void)didDismissMoreApps:(NSString *)location {
    NSLog(@"dismissed more apps page at location %@", location);
}

/*
 * didCompleteRewardedVideo
 *
 * This is called when a rewarded video has been viewed
 *
 * Is fired on:
 * - Rewarded video completed view
 *
 */
- (void)didCompleteRewardedVideo:(CBLocation)location withReward:(int)reward {
    NSLog(@"completed rewarded video view at location %@ with reward amount %d", location, reward);
}

/*
 * didFailToLoadRewardedVideo
 *
 * This is called when a Rewarded Video has failed to load. The error enum specifies
 * the reason of the failure
 */

- (void)didFailToLoadRewardedVideo:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Rewarded Video, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Rewarded Video, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Rewarded Video, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Rewarded Video, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Rewarded Video, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Rewarded Video, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Rewarded Video, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Rewarded Video, session not started !");
        } break;
        case CBLoadErrorNoLocationFound : {
            NSLog(@"Failed to load Rewarded Video, missing location parameter !");
        } break;
        default: {
            NSLog(@"Failed to load Rewarded Video, unknown error !");
        }
    }
}

/*
 * didDisplayInterstitial
 *
 * Called after an interstitial has been displayed on the screen.
 */

- (void)didDisplayInterstitial:(CBLocation)location {
    NSLog(@"Did display interstitial");
    
    // We might want to pause our in-game audio, lets double check that an ad is visible
    if ([Chartboost isAnyViewVisible]) {
        // Use this function anywhere in your logic where you need to know if an ad is visible or not.
        NSLog(@"Pause audio");
    }
}


/*!
 @abstract
 Called after an InPlay object has been loaded from the Chartboost API
 servers and cached locally.
 
 @param location The location for the Chartboost impression type.
 
 @discussion Implement to be notified of when an InPlay object has been loaded from the Chartboost API
 servers and cached locally for a given CBLocation.
 */
- (void)didCacheInPlay:(CBLocation)location {
    NSLog(@"Successfully cached inPlay");
    ViewController *vc = (ViewController*)self.window.rootViewController;
    [vc renderInPlay:[Chartboost getInPlay:location]];
}

/*!
 @abstract
 Called after a InPlay has attempted to load from the Chartboost API
 servers but failed.
 
 @param location The location for the Chartboost impression type.
 
 @param error The reason for the error defined via a CBLoadError.
 
 @discussion Implement to be notified of when an InPlay has attempted to load from the Chartboost API
 servers but failed for a given CBLocation.
 */
- (void)didFailToLoadInPlay:(CBLocation)location
                  withError:(CBLoadError)error {
    
    NSString *errorString = @"";
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            errorString = @"Failed to load In Play, no Internet connection !";
        } break;
        case CBLoadErrorInternal: {
            errorString = @"Failed to load In Play, internal error !";
        } break;
        case CBLoadErrorNetworkFailure: {
            errorString = @"Failed to load In Play, network errorString !";
        } break;
        case CBLoadErrorWrongOrientation: {
            errorString = @"Failed to load In Play, wrong orientation !";
        } break;
        case CBLoadErrorTooManyConnections: {
            errorString = @"Failed to load In Play, too many connections !";
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            errorString = @"Failed to load In Play, first session !";
        } break;
        case CBLoadErrorNoAdFound : {
            errorString = @"Failed to load In Play, no ad found !";
        } break;
        case CBLoadErrorSessionNotStarted : {
            errorString = @"Failed to load In Play, session not started !";
        } break;
        case CBLoadErrorNoLocationFound : {
            errorString = @"Failed to load In Play, missing location parameter !";
        } break;
        default: {
            errorString = @"Failed to load In Play, unknown error !";
        }
    }
    
    NSLog(@"Error: %@", errorString);
    
    ViewController *vc = (ViewController*)self.window.rootViewController;
    [vc renderInPlayError:errorString];
}

@end
