//
//  BNRAppDelegate.m
//  HomePwner
//
//  Created by John Gallagher on 1/7/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRAppDelegate.h"
#import "BNRItemsViewController.h"
#import "BNRItemStore.h"
#import <objc/message.h>
#import "CalculateMaker.h"
#import "BNRRACTestViewController.h"

@interface BNRAppDelegate ()
@property (nonatomic, strong) BNRRACTestViewController *rac_TestViewController;
@end

@implementation BNRAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    if (!self.window.rootViewController) {
//        // Create a BNRItemsViewController
//        BNRItemsViewController *itemsViewController = [[BNRItemsViewController alloc] init];
//        
//        // Create an instance of a UINavigationController
//        // its stack contains only itemsViewController
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:itemsViewController];
//        
//        navController.restorationIdentifier = NSStringFromClass([navController class]);
//        
//        
//        // Place navigation controller's view in the window hierarchy
//        self.window.rootViewController = navController;
//    }
//
//    [self.window makeKeyAndVisible];
#pragma mark - Runtime test
    NSString *nameString = @"Mikey Ward";
    NSString *capsName = objc_msgSend(nameString, @selector(uppercaseString));
    NSLog(@"%@ -> %@", nameString, capsName);
    
    NSString *string1 = @"abcd";
    NSString *string2 = @"abcde";
    NSString *string3 = @"abcd";
    BOOL equal = [string1 isEqualToString:string2];
    equal = [string1 isEqualToString:string3];
    
#pragma mark - Chaining method
    int result1 = [CalculateMaker cal_calculateMaker:^(CalculateMaker *maker) {
        maker.add(10).sub(5).multi(4).divide(2);
    }];
    
    int result2 = [CalculateMaker cal_calculateMaker:^(CalculateMaker *maker) {
        maker.add(30).sub(22).multi(6).divide(4);
    }];
    
    NSLog(@"result1: %i, result2: %i", result1, result2);
    
    
#pragma mark - RAC test
    self.rac_TestViewController = [BNRRACTestViewController new];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    BOOL success = [[BNRItemStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all of the BNRItems");
    } else {
        NSLog(@"Could not save any of the BNRItems");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

- (UIViewController *)application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    UIViewController *vc = [[UINavigationController alloc] init];
    vc.restorationIdentifier = [identifierComponents lastObject];
    
    if (identifierComponents.count == 1) {
        self.window.rootViewController = vc;
    }
    
    return vc;
}

@end

