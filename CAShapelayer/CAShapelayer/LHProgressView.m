//
//  LHProgressView.m
//  CAShapelayer
//
//  Created by Hanguang on 4/24/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "LHProgressView.h"

@implementation LHProgressView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createProgressBar];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createProgressBar];
    }
    return self;
}

- (void)createProgressBar {
    CGFloat startAngle = M_PI_2;
    CGFloat endAngle = 2 * M_PI + M_PI_2;
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    CAGradientLayer *gradientLayer = [self gradientLayer];
    CAShapeLayer *progressLayer = [CAShapeLayer layer];
    progressLayer.path = [UIBezierPath bezierPathWithArcCenter:centerPoint radius:CGRectGetWidth(self.frame) / 2 - 30.0
                                                    startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    progressLayer.fillColor = nil;
    progressLayer.strokeColor = [UIColor blackColor].CGColor;
    progressLayer.lineWidth = 4.0;
    progressLayer.strokeStart = 0.0;
    progressLayer.strokeEnd = 0.0;
    
    gradientLayer.mask = progressLayer;
    [self.layer addSublayer:gradientLayer];
}

- (CAGradientLayer *)gradientLayer {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    
    gradientLayer.locations = @[@0.0, @1.0];
    
    id colorTop = (id)[UIColor colorWithRed:1.0 green:213/255.0 blue:63/255.0 alpha:1.0].CGColor;
    id colorButtom = (id)[UIColor colorWithRed:1.0 green:198/255.0 blue:5/255.0 alpha:1.0].CGColor;
    gradientLayer.colors = @[colorTop, colorButtom];
    
    return gradientLayer;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
