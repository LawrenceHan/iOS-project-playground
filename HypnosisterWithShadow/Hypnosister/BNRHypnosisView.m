//
//  BNRHypnosisView.m
//  Hypnosister
//
//  Created by John Gallagher on 1/6/14.
//  Copyright (c) 2014 John Gallagher. All rights reserved.
//

#import "BNRHypnosisView.h"

@implementation BNRHypnosisView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // All BNRHypnosisViews start with a clear background color
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;

    // Figure out the center of the bounds rectangle
    CGPoint center;
    center.x = bounds.origin.x + bounds.size.width / 2.0;
    center.y = bounds.origin.y + bounds.size.height / 2.0;

    // The largest circle will circumstribe the view
    float maxRadius = hypot(bounds.size.width, bounds.size.height) / 2.0;

    UIBezierPath *path = [[UIBezierPath alloc] init];

    for (float currentRadius = maxRadius; currentRadius > 0; currentRadius -= 20) {
        [path moveToPoint:CGPointMake(center.x + currentRadius, center.y)];

        [path addArcWithCenter:center
                        radius:currentRadius
                    startAngle:0.0
                      endAngle:M_PI * 2.0
                     clockwise:YES];
    }

    // Configure line width to 10 points
    path.lineWidth = 10;

    // Configure the drawing color to light gray
    [[UIColor lightGrayColor] setStroke];

    // Draw the line!
    [path stroke];
    
    // Get current context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Save current context state
    CGContextSaveGState(currentContext);
    
    // Draw a triangle
    CGFloat sideLength = 200;
    CGPoint tp1 = CGPointMake((self.bounds.size.width - sideLength)/2, (self.bounds.size.height - sideLength)/2 + sideLength);
    CGPoint tp2 = CGPointMake(tp1.x + sideLength/2, (self.bounds.size.height - sideLength)/2);
    CGPoint tp3 = CGPointMake(tp1.x + sideLength, tp1.y);
    
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:tp1];
    [trianglePath addLineToPoint:tp2];
    [trianglePath addLineToPoint:tp3];
    [trianglePath closePath];
    [trianglePath stroke];
    
    [trianglePath addClip];
    
    // Draw gradient color
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {1.0, 1.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0};
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
    
    CGPoint startPoint = CGPointMake(tp2.x, tp1.y);
    CGPoint endPoint = CGPointMake(tp2.x, tp2.y);
    CGContextDrawLinearGradient(currentContext, gradient,
                                startPoint, endPoint,
                                kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorspace);
    
    // Restore current context
    CGContextRestoreGState(currentContext);
    
    
    // Save the state of current context for later restore
    CGContextSaveGState(currentContext);
    
    // Set shadow context
    CGContextSetShadow(currentContext, CGSizeMake(4, 7), 3);
    // Draw a image on view
    UIImage *image = [UIImage imageNamed:@"logo"];
    [image drawInRect:CGRectMake((self.bounds.size.width - image.size.width/2)/2,
                                 (self.bounds.size.height - image.size.height/2)/2,
                                 image.size.width / 2, image.size.height / 2)];
    
    // Restore current context
    CGContextRestoreGState(currentContext);
    
}

@end
