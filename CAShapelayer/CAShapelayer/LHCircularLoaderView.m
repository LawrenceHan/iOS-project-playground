
//
//  LHCircularLoaderView.m
//  CAShapelayer
//
//  Created by Hanguang on 4/22/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "LHCircularLoaderView.h"
IB_DESIGNABLE
@interface LHCircularLoaderView ()
@property (nonatomic, strong) CAShapeLayer *circlePathLayer;
@property (nonatomic, assign) CGFloat circleRadius;

@end

@implementation LHCircularLoaderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.path = [self circlePath].CGPath;
}

- (void)configure {
    self.circleRadius = 20.0;
    _circlePathLayer = [CAShapeLayer layer];
    _circlePathLayer.frame = self.bounds;
    _circlePathLayer.lineWidth = 2.0;
    _circlePathLayer.fillColor = [UIColor clearColor].CGColor;
    _circlePathLayer.strokeColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:_circlePathLayer];
    self.backgroundColor = [UIColor whiteColor];
    self.indicatorProgress = 0.0;
}

- (CGRect)circleFrame {
    CGRect circleFrame = CGRectMake(0, 0, 2 * _circleRadius, 2 * _circleRadius);
    circleFrame.origin.x = CGRectGetMidX(_circlePathLayer.bounds) - CGRectGetMidX(circleFrame);
    circleFrame.origin.y = CGRectGetMidY(_circlePathLayer.bounds) - CGRectGetMidY(circleFrame);
    
    return circleFrame;
}

- (UIBezierPath *)circlePath {
    return [UIBezierPath bezierPathWithOvalInRect:[self circleFrame]];
}

- (CGFloat)indicatorProgress {
    return _circlePathLayer.strokeEnd;
}

- (void)setIndicatorProgress:(CGFloat)indicatorProgress {
    if (indicatorProgress > 1) {
        _circlePathLayer.strokeEnd = 1;
    } else if (indicatorProgress < 0) {
        _circlePathLayer.strokeEnd = 0;
    } else {
        _circlePathLayer.strokeEnd = indicatorProgress;
    }
}

- (void)reveal {
    self.backgroundColor = [UIColor clearColor];
    self.indicatorProgress = 1.0;
    [_circlePathLayer removeAnimationForKey:@"strokeEnd"];
    [_circlePathLayer removeFromSuperlayer];
    self.superview.layer.mask = _circlePathLayer;
    
    // 1
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat finalRadius = sqrt((center.x * center.x) + (center.y * center.y));
    CGFloat radiusInset = finalRadius - _circleRadius;
    CGRect outerRect = CGRectInset([self circleFrame], -radiusInset, -radiusInset);
    CGPathRef toPath = [UIBezierPath bezierPathWithOvalInRect:outerRect].CGPath;
    
    // 2
    CGPathRef fromPath = _circlePathLayer.path;
    CGFloat fromLineWidth = _circlePathLayer.lineWidth;
    
    // 3
    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    _circlePathLayer.lineWidth = 2 * finalRadius;
    _circlePathLayer.path = toPath;
    [CATransaction commit];
    
    // 4
    CABasicAnimation *lineWidthAnimation = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
    lineWidthAnimation.fromValue = @(fromLineWidth);
    lineWidthAnimation.toValue = @(2 * finalRadius);
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (__bridge id)(fromPath);
    pathAnimation.toValue = (__bridge id)(toPath);
    
    // 5
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.duration = 1.0;
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    groupAnimation.animations = @[pathAnimation, lineWidthAnimation];
    groupAnimation.delegate = self;
    [_circlePathLayer addAnimation:groupAnimation forKey:@"strokeWidth"];
    
}

#pragma mark - Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.superview.layer.mask = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
