/*
 * ViewController.m
 * ChartboostExampleApp
 *
 * Copyright (c) 2013 Chartboost. All rights reserved.
 */

#import "ViewController.h"
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBAnalytics.h>
#import <Chartboost/CBInPlay.h>

#import <StoreKit/StoreKit.h>

static NSUInteger inPlaySuccessViewTag = 999;
static NSUInteger inPlayErrorViewTag = 888;
static NSUInteger piaViewTag = 888;
static NSUInteger errorLabelViewTag = 777;
static NSUInteger closeButtonLabelTag = 666;
static NSUInteger errorTitleViewTag = 555;
static NSUInteger appIconTag = 444;
static NSUInteger appNameTag = 333;
static NSUInteger iconTitleTag = 222;
static NSUInteger nameTitleTag = 111;

NSString *const PIAGlobalLevelNumberKey = @"globalLevelNumber";

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ViewController ()

@property (nonatomic, strong) CBInPlay *inPlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    // Setup PIA number in NSUserDefaults
    NSUInteger globalLevel = [[NSUserDefaults standardUserDefaults] integerForKey:PIAGlobalLevelNumberKey];
    if (globalLevel <= 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:PIAGlobalLevelNumberKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.inPlayShowing = NO;
    self.piaShowing = NO;
    self.inPlayShowingError = NO;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showInterstitial {
    [Chartboost showInterstitial:CBLocationHomeScreen];
}

- (IBAction)showMoreApps {
    [Chartboost showMoreApps:self location:CBLocationHomeScreen];
}

- (IBAction)cacheInterstitial {
    [Chartboost cacheInterstitial:CBLocationHomeScreen];
}

- (IBAction)cacheMoreApps {
    [Chartboost cacheMoreApps:CBLocationHomeScreen];
}

- (IBAction)cacheRewardedVideo {
    [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
}

- (IBAction)showRewardedVideo {
    [Chartboost showRewardedVideo:CBLocationMainMenu];
}

- (IBAction)showSupport:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://answers.chartboost.com"]];
}

- (IBAction)showInPlay:(id)sender {
    [Chartboost cacheInPlay:CBLocationHomeScreen];
}

- (void)renderInPlay:(CBInPlay*)inPlay {
    if (self.inPlayShowing) {
        return;
    }
    self.inPlayShowing = YES;
    self.inPlay = inPlay;
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat width = screenWidth;
    CGFloat height = screenHeight;
    CGFloat x = 0;
    CGFloat y = 0;
   
    CGRect overlayFrame = CGRectMake(x, y, width, height);
    UIView *blur = [UIView new];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        blur = [[UIView alloc] initWithFrame:overlayFrame];
        blur.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    } else {
        blur = [[UIToolbar alloc] initWithFrame:overlayFrame];
        ((UIToolbar*)blur).barStyle = UIBarStyleBlack;
        ((UIToolbar*)blur).translucent = YES;
    }
    
    // Add inPlay SubViews
    UIImage *appIconImage = [UIImage imageWithData:inPlay.appIcon];
    CGRect iconFrame = CGRectMake(screenWidth/2.0f - [appIconImage size].width/2.0f, 30.0f, [appIconImage size].width, [appIconImage size].height);
    
    UIButton *appIcon = [[UIButton alloc] initWithFrame:iconFrame];
    [appIcon setImage:appIconImage forState:UIControlStateNormal];
    [appIcon addTarget:self action:@selector(clickInPlay:) forControlEvents:UIControlEventTouchUpInside];
    appIcon.tag = appIconTag;
    
    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, appIcon.frame.origin.y + appIcon.frame.size.height + 50.0f, 999.0f, 999.0f)];
    appName.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    appName.text = inPlay.appName;
    [appName sizeToFit];
    appName.frame = CGRectMake(screenWidth/2.0f - appName.frame.size.width/2.0f, appName.frame.origin.y, appName.frame.size.width, appName.frame.size.height);
    appName.textColor = [UIColor whiteColor];
    appName.backgroundColor = [UIColor clearColor];
    appName.tag = appNameTag;
    
    UILabel *iconTitle = [[UILabel alloc] initWithFrame:CGRectMake(appIcon.frame.origin.x, appIcon.frame.origin.y + appIcon.frame.size.height + 3.0f, appIcon.frame.size.width, 10.0f)];
    iconTitle.font = [UIFont systemFontOfSize:9.0f];
    iconTitle.textColor = [UIColor whiteColor];
    iconTitle.textAlignment = NSTextAlignmentCenter;
    iconTitle.text = @"App Icon";
    iconTitle.backgroundColor = [UIColor clearColor];
    iconTitle.tag = iconTitleTag;
    
    UILabel *nameTitle = [[UILabel alloc] initWithFrame:CGRectMake(appName.frame.origin.x, appName.frame.origin.y + appName.frame.size.height + 3.0f, appName.frame.size.width, 10.0f)];
    nameTitle.font = [UIFont systemFontOfSize:9.0f];
    nameTitle.textColor = [UIColor whiteColor];
    nameTitle.textAlignment = NSTextAlignmentCenter;
    nameTitle.text = @"App Name";
    nameTitle.backgroundColor = [UIColor clearColor];
    nameTitle.tag = nameTitleTag;
    
    CGFloat buttonWidth = 50.0f;
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, buttonWidth, buttonWidth)];
    [closeButton addTarget:self action:@selector(closeButtonInPlay:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *closeButtonLabel = [[UILabel alloc] initWithFrame:closeButton.frame];
    closeButtonLabel.text = @"\U00002715";
    closeButtonLabel.font = [UIFont systemFontOfSize:35.0f];
    closeButtonLabel.textColor = [UIColor whiteColor];
    closeButtonLabel.textAlignment = NSTextAlignmentCenter;
    closeButtonLabel.backgroundColor = [UIColor clearColor];
    closeButtonLabel.tag = closeButtonLabelTag;
    
    [blur addSubview:closeButton];
    [blur addSubview:closeButtonLabel];
    [blur addSubview:appIcon];
    [blur addSubview:appName];
    [blur addSubview:iconTitle];
    [blur addSubview:nameTitle];
    
    blur.tag = inPlaySuccessViewTag;
    blur.alpha = 0.0f;
    [self.view addSubview:blur];
    
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view viewWithTag:inPlaySuccessViewTag].alpha = 1.0f;
    } completion:^(BOOL finished){
        [self.inPlay show];
    }];
    self.inPlayShowing = YES;
}

- (void)closeButtonInPlay:(id)button {
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view viewWithTag:inPlaySuccessViewTag].alpha = 0.0f;
    } completion:^(BOOL finished){
        [[self.view viewWithTag:inPlaySuccessViewTag] removeFromSuperview];
        self.inPlayShowing = NO;
    }];
}

- (void)clickInPlay:(id)button {
    [self.inPlay click];
}

- (IBAction)sendPIALevelTracking:(id)sender {
    NSLog(@"sendPIA level tracking");
    NSUInteger highestLevel = [[NSUserDefaults standardUserDefaults] integerForKey:PIAGlobalLevelNumberKey];
    CBLevelType levelType = HIGHEST_LEVEL_REACHED;
    NSString *eventLabel = @"character level";
    NSString *eventDescription = @"highest level";
    NSUInteger subLevel = 0;
    [CBAnalytics trackLevelInfo:eventLabel eventField:levelType mainLevel:highestLevel subLevel:subLevel description:eventDescription];
    
    [self renderPIALevelTrackingAlertWithLabel:eventLabel levelType:levelType mainLevel:highestLevel subLevel:subLevel description:eventDescription];
    
    [[NSUserDefaults standardUserDefaults] setInteger:(highestLevel+1) forKey:PIAGlobalLevelNumberKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)stringForCBLevelType:(CBLevelType)levelType {
    if (levelType == HIGHEST_LEVEL_REACHED) {
        return @"HIGHEST_LEVEL_REACHED";
    } else if (levelType == CURRENT_AREA) {
        return @"CURRENT_AREA";
    } else if (levelType == OTHER_NONSEQUENTIAL) {
        return @"OTHER_NONSEQUENTIAL";
    } else if (levelType == OTHER_SEQUENTIAL) {
        return @"OTHER_SEQUENTIAL";
    } else {
        return @"CHARACTER_LEVEL";
    }
}

- (void)renderPIALevelTrackingAlertWithLabel:(NSString*)eventLabel levelType:(CBLevelType)levelType mainLevel:(NSUInteger)mainLevel subLevel:(NSUInteger)subLevel description:(NSString*)eventDescription {
    if (self.piaShowing) {
        return;
    }
    self.piaShowing = YES;
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat width = screenWidth;
    CGFloat height = screenHeight;
    CGFloat x = 0;
    CGFloat y = 0;
    
    CGRect overlayFrame = CGRectMake(x, y, width, height);
    UIView *blur = [UIView new];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        blur = [[UIView alloc] initWithFrame:overlayFrame];
        blur.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    } else {
        blur = [[UIToolbar alloc] initWithFrame:overlayFrame];
        ((UIToolbar*)blur).barStyle = UIBarStyleBlack;
        ((UIToolbar*)blur).translucent = YES;
    }
    NSLog(@"Width & height: %f %f", width, height);

    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    errorLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    errorLabel.numberOfLines = 5;
    errorLabel.textAlignment = NSTextAlignmentLeft;
    errorLabel.text = [NSString stringWithFormat:@"Event Label - %@\nMain Level - %lu\nSub Level - %lu\nDescription - %@\n Level Type - %@", eventLabel, (unsigned long)mainLevel, (unsigned long)subLevel, eventDescription, [self stringForCBLevelType:levelType]];
    [errorLabel sizeToFit];
    errorLabel.frame = CGRectMake(screenWidth/2.0f - errorLabel.frame.size.width/2.0f, screenHeight/2.0f - errorLabel.frame.size.height/2.0f, errorLabel.frame.size.width, errorLabel.frame.size.height);
    errorLabel.textColor = [UIColor whiteColor];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.tag = errorLabelViewTag;
    
    CGFloat buttonWidth = 50.0f;
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, buttonWidth, buttonWidth)];
    [closeButton addTarget:self action:@selector(closeButtonPIA:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *closeButtonLabel = [[UILabel alloc] initWithFrame:closeButton.frame];
    closeButtonLabel.text = @"\U00002715";
    closeButtonLabel.font = [UIFont systemFontOfSize:35.0f];
    closeButtonLabel.textColor = [UIColor whiteColor];
    closeButtonLabel.textAlignment = NSTextAlignmentCenter;
    closeButtonLabel.backgroundColor = [UIColor clearColor];
    closeButtonLabel.tag = closeButtonLabelTag;
    
    [blur addSubview:closeButton];
    [blur addSubview:closeButtonLabel];
    [blur addSubview:errorLabel];
    blur.tag = piaViewTag;
    blur.alpha = 0.0f;
    [self.view addSubview:blur];
    
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view viewWithTag:piaViewTag].alpha = 1.0f;
    } completion:^(BOOL finished){
        
    }];
    self.piaShowing = YES;
}

- (void)closeButtonPIA:(id)button {
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view viewWithTag:piaViewTag].alpha = 0.0f;
    } completion:^(BOOL finished){
        [[self.view viewWithTag:piaViewTag] removeFromSuperview];
        self.piaShowing = NO;
    }];
}

- (void)renderInPlayError:(NSString *)error {
    if (self.inPlayShowingError) {
        return;
    }
    self.inPlayShowingError = YES;
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat width = screenWidth;
    CGFloat height = screenHeight;
    CGFloat x = 0;
    CGFloat y = 0;
    
    CGRect overlayFrame = CGRectMake(x, y, width, height);
    UIView *blur = [UIView new];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        blur = [[UIView alloc] initWithFrame:overlayFrame];
        blur.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    } else {
        blur = [[UIToolbar alloc] initWithFrame:overlayFrame];
        ((UIToolbar*)blur).barStyle = UIBarStyleBlack;
        ((UIToolbar*)blur).translucent = YES;
    }
    
    
    // Add inPlay SubViews
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 999.0f, 999.0f)];
    errorLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
    errorLabel.text = error;
    [errorLabel sizeToFit];
    errorLabel.frame = CGRectMake(screenWidth/2.0f - errorLabel.frame.size.width/2.0f, screenHeight/2.0f - errorLabel.frame.size.height/2.0f, errorLabel.frame.size.width, errorLabel.frame.size.height);
    errorLabel.textColor = [UIColor whiteColor];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.tag = errorLabelViewTag;
    
    UILabel *errorTitle = [[UILabel alloc] initWithFrame:CGRectMake(errorLabel.frame.origin.x, errorLabel.frame.origin.y + errorLabel.frame.size.height + 3.0f, errorLabel.frame.size.width, 10.0f)];
    errorTitle.font = [UIFont systemFontOfSize:9.0f];
    errorTitle.textColor = [UIColor whiteColor];
    errorTitle.textAlignment = NSTextAlignmentCenter;
    errorTitle.text = @"Error";
    errorTitle.backgroundColor = [UIColor clearColor];
    errorTitle.tag = errorTitleViewTag;
    
    CGFloat buttonWidth = 50.0f;
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 5.0f, buttonWidth, buttonWidth)];
    [closeButton addTarget:self action:@selector(closeButtonInPlayError:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *closeButtonLabel = [[UILabel alloc] initWithFrame:closeButton.frame];
    closeButtonLabel.text = @"\U00002715";
    closeButtonLabel.font = [UIFont systemFontOfSize:35.0f];
    closeButtonLabel.textColor = [UIColor whiteColor];
    closeButtonLabel.textAlignment = NSTextAlignmentCenter;
    closeButtonLabel.backgroundColor = [UIColor clearColor];
    closeButtonLabel.tag = closeButtonLabelTag;
    
    [blur addSubview:closeButton];
    [blur addSubview:closeButtonLabel];
    [blur addSubview:errorLabel];
    [blur addSubview:errorTitle];
    blur.tag = inPlayErrorViewTag;
    blur.alpha = 0.0f;
    [self.view addSubview:blur];
    
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view viewWithTag:inPlayErrorViewTag].alpha = 1.0f;
    } completion:^(BOOL finished){
        
    }];
    self.inPlayShowingError = YES;
}

- (void)closeButtonInPlayError:(id)button {
    [UIView animateWithDuration:0.3f animations:^(void){
        [self.view viewWithTag:inPlayErrorViewTag].alpha = 0.0f;
    } completion:^(BOOL finished){
        [[self.view viewWithTag:inPlayErrorViewTag] removeFromSuperview];
        self.inPlayShowingError = NO;
    }];
}
/*
 * This is an example of how to call the Chartboost Post Install Analytics API.
 * To fully use this feature you must implement the Apple In-App Purchase
 *
 * Checkout https://developer.apple.com/in-app-purchase/ for information on how to setup your app to use StoreKit
 */
- (void)trackInAppPurchase:(NSData *)transactionReceipt product:(SKProduct *)product {
    [CBAnalytics trackInAppPurchaseEvent:transactionReceipt product:product];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if(self.piaShowing) {
        UIView *view = [self.view viewWithTag:inPlayErrorViewTag];
        view.frame = self.view.bounds;
        
        UIView *errorLabelView = [view viewWithTag:errorLabelViewTag];
        [errorLabelView sizeToFit];
        
        CGRect errorLabelFrame = errorLabelView.bounds;
        errorLabelFrame.origin = CGPointMake((view.frame.size.width - errorLabelFrame.size.width)/2.0f, (view.frame.size.height - errorLabelFrame.size.height)/2.0f);
        errorLabelView.frame = errorLabelFrame;
    }
    
    if(self.inPlayShowingError) {
        UIView *view = [self.view viewWithTag:inPlayErrorViewTag];
        view.frame = self.view.bounds;
        
        UIView *errorLabelView = [view viewWithTag:errorLabelViewTag];
        [errorLabelView sizeToFit];
        
        CGRect errorLabelFrame = errorLabelView.bounds;
        errorLabelFrame.origin = CGPointMake((view.frame.size.width - errorLabelFrame.size.width)/2.0f, (view.frame.size.height - errorLabelFrame.size.height)/2.0f);
        errorLabelView.frame = errorLabelFrame;
    
        UIView *errorTitleView = [view viewWithTag:errorTitleViewTag];
        errorTitleView.frame = CGRectMake(errorLabelView.frame.origin.x, errorLabelView.frame.origin.y + errorLabelView.frame.size.height + 3.0f, errorLabelView.frame.size.width, 10.0f);
    }
    
    if(self.inPlayShowing) {
        UIView *view = [self.view viewWithTag:inPlaySuccessViewTag];
        view.frame = self.view.bounds;
        
        UIView *appIconView = [view viewWithTag:appIconTag];
        appIconView.frame = CGRectMake((view.frame.size.width - appIconView.frame.size.width)/2.0f, 30.0f, appIconView.frame.size.width, appIconView.frame.size.height);
        
        UIView *appNameView = [view viewWithTag:appNameTag];
        appNameView.frame = CGRectMake((view.frame.size.width - appNameView.frame.size.width)/2.0f, appIconView.frame.origin.y + appIconView.frame.size.height + 50.0f, appNameView.frame.size.width, appNameView.frame.size.height);
        
        UIView *iconTitleView = [view viewWithTag:iconTitleTag];
        iconTitleView.frame = CGRectMake(appIconView.frame.origin.x, appIconView.frame.origin.y + appIconView.frame.size.height + 3.0f, appIconView.frame.size.width, 10.0f);
        
        UIView *nameTitleView = [view viewWithTag:nameTitleTag];
        nameTitleView.frame = CGRectMake(appNameView.frame.origin.x, appNameView.frame.origin.y + appNameView.frame.size.height + 3.0f, appNameView.frame.size.width, 10.0f);
    }
}

@end
