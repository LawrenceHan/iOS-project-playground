//
//  MainWindowController.m
//  OAuthDemoObjc
//
//  Created by Hanguang on 1/16/16.
//  Copyright © 2016 Hanguang. All rights reserved.
//

#import "MainWindowController.h"
#import "AuthenticationManager.h"

@interface MainWindowController ()
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSTextField *passwordTextField;
@property (weak) IBOutlet NSButton *signinButton;
@property (weak) IBOutlet NSButton *myProfileButton;
@property (nonatomic, strong) AuthenticationManager *manager;

@end


@implementation MainWindowController

- (NSString *)windowNibName {
    return @"MainWindowController";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.manager = [AuthenticationManager new];
    
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter]
     rac_addObserverForName:AFNetworkActivityLoggerNotification object:nil]
    map:^id(NSNotification *notification) {
        return notification.object;
    }] subscribeNext:^(NSString *log) {
        if (log.length) {
            if (self.textView.textStorage.length) {
                log = [NSString stringWithFormat:@"\n%@", log];
            }
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:log];
            [self.textView.textStorage appendAttributedString:string];
        }
    }];
    
    RACSignal *nameSignal = self.usernameTextField.rac_textSignal;
    RACSignal *passwordSignal = self.passwordTextField.rac_textSignal;
    
    RACSignal *enableSignal =
    [RACSignal combineLatest:@[nameSignal, passwordSignal]
                      reduce:^id(NSString *name, NSString *password) {
                          return @(name.length && password.length);
    }];
    
    self.signinButton.rac_command =
    [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        RACSignal *loginSignal = [[self.manager requestForAccessToken]
                                  concat:[self.manager requestForOAuthWithUsername:self.usernameTextField.stringValue
                                                                          password:self.passwordTextField.stringValue]];
        return loginSignal;
    }];
    
    self.myProfileButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [self.manager getMyProfile];
    }];
    
    RAC(self.usernameTextField, enabled) = [self.signinButton.rac_command.executing not];
    RAC(self.passwordTextField, enabled) = [self.signinButton.rac_command.executing not];
}


@end
