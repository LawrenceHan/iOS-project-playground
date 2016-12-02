//
//  AppDelegate.m
//  Puzzle
//
//  Created by Hanguang on 02/12/2016.
//  Copyright © 2016 Hanguang. All rights reserved.
//

#import "AppDelegate.h"
#import "Puzzle.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    // Your execution code
    Puzzle *puzzle = [[Puzzle alloc] initWithBeginFrame:@"wrbbrrbbrrbbrrbb" endFrame:@"wbrbbrbrrbrbbrbr" columns:4 row:4];
    [puzzle calculateSteps];
    CFAbsoluteTime executionTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"Dispatch took %f s", executionTime);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
