//
//  LHProgressView.m
//  CAShapelayer
//
//  Created by Hanguang on 4/24/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "LHProgressView.h"
IB_DESIGNABLE
@implementation LHProgressView {
    CAShapeLayer *progressLayer;
    CAGradientLayer *gradientLayer;
    UILabel *loadingLabel;
}

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
    self.backgroundColor = [UIColor whiteColor];
    CGFloat startAngle = M_PI_2;
    CGFloat endAngle = 2 * M_PI + M_PI_2;
    CGPoint centerPoint = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    gradientLayer = [self gradientLayer];
    progressLayer = [CAShapeLayer layer];
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
    CAGradientLayer *gradien = [CAGradientLayer layer];
    gradien.frame = self.bounds;
    
    gradien.locations = @[@0.0, @1.0];
    
    id colorTop = (id)[UIColor redColor].CGColor;
    id colorButtom = (id)[UIColor greenColor].CGColor;
    gradien.colors = @[colorTop, colorButtom];
    
    return gradien;
}

- (void)animateProgressView {
    loadingLabel = [UILabel new];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading";
    loadingLabel.textColor = [UIColor blueColor];
    [loadingLabel sizeToFit];
    CGFloat width, height;
    width = loadingLabel.frame.size.width;
    height = loadingLabel.frame.size.height;
    CGRect labelFrame = CGRectMake(0, 0, width, height);
    labelFrame.origin.x = CGRectGetMidX(self.bounds) - CGRectGetMidX(labelFrame);
    labelFrame.origin.y = CGRectGetMidY(self.bounds) - CGRectGetMidY(labelFrame);
    loadingLabel.frame = labelFrame;
    [self addSubview:loadingLabel];
    
    progressLayer.strokeStart = 0.0;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.fromValue = @(0.0);
    animation.toValue = @(2.0);
    animation.duration = 1.0;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.additive = YES;
    animation.fillMode = kCAFillModeForwards;
    
    [progressLayer addAnimation:animation forKey:@"strokeEnd"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    loadingLabel.text = @"Done";
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
