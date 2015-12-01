//
//  MRBridge+MPSpecs.h
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MRBridge.h"

@interface MRBridge (MPSpecs) <UIWebViewDelegate>

@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, readonly) MRNativeCommandHandler *nativeCommandHandler;

- (void)fireNativeCommandCompleteEvent:(NSString *)command;

@end
