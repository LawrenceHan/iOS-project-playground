//
//  LHCircularLoaderView.h
//  CAShapelayer
//
//  Created by Hanguang on 4/22/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHCircularLoaderView : UIView

@property (nonatomic, strong) IBInspectable UIColor *color;
@property (nonatomic, assign) IBInspectable CGFloat indicatorProgress;

- (void)reveal;
@end
