//
//  MPNativeVideoView.h
//  MoPubSampleApp
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"


@interface MPNativeVideoView : UIView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *mainTextLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UIImageView *mainImageView;
@property (strong, nonatomic) UIView *videoView;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;

@end
