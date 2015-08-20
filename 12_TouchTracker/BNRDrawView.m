//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by Hanguang on 14-6-5.
//  Copyright (c) 2014年 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"

#define PI 3.1415926535;

@interface BNRDrawView ()

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;
@property (nonatomic, strong) NSMutableDictionary *circleInProgress;
@property (nonatomic, strong) NSMutableArray *finishedCircle;
@property (nonatomic, strong) NSValue *touchBeginKey;
@property (nonatomic, strong) NSValue *touchEndKey;

@end

@implementation BNRDrawView

#pragma mark - init method
- (instancetype)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];
    
    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.circleInProgress = [[NSMutableDictionary alloc] init];
        self.finishedCircle = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
    }
    return self;
}


#pragma mark - draw method 画图方法
- (void)strokeLine:(BNRLine *)line
{
    [self strokeLine:line isInProgress:NO];
}

- (void)strokeLine:(BNRLine *)line isInProgress:(BOOL)inProgress {
/*
    UIColor *color;
    // 通过line.angle属性 动态分配当前画笔颜色
    // 根据角度设置线的颜色，这里调用[UIColor colorWithRed:green:blue:alpha:]
    // 四个参数对应的取值范围都是 0.0 - 1.0，所以我的思路是 0度 - 360度 对应 0.0 - 1.0
    int angle = fabs(line.angle);
    CGFloat randomRed = ((angle * arc4random()) % 100) / 100.f;
    CGFloat randomGreen = ((angle * arc4random()) % 100) / 100.f;
    CGFloat randomBlue = ((angle * arc4random()) % 100) / 100.f;
    if (inProgress) {
        
        color = [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1.0];
    } else {
        color = [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1.0];
    }
*/
    [line.lineColor set];
    UIBezierPath *bp = [UIBezierPath bezierPath];
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

// 画圆Blocks
// void (^drawCircle) (BNRLine *) = ^(BNRLine *circle)
- (void)drawCircle:(BNRLine *)circle
{
    // 生成高和宽
    float width,height;
    //
    width = circle.end.x - circle.begin.x;
    height = circle.end.y - circle.begin.y;
    
    // 生成矩形
    CGRect rect = CGRectMake(circle.begin.x,circle.begin.y,width,height);
    // 根据矩形成生内切圆
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    circlePath.lineWidth = 7;
    circlePath.lineCapStyle = kCGLineCapRound;
    [circlePath stroke];
    
}

// 每次触摸开始，移动都重新画图，调用下面的方法
- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    //[[UIColor blackColor] set];
    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
    }
    
    //[[UIColor redColor] set];
    for (NSValue *key in self.linesInProgress) {
        BNRLine *line = self.linesInProgress[key];
        //NSLog(@"draw key is %@", key);
        [self strokeLine:line isInProgress:YES];
    }
    
    if (_touchBeginKey) {
        // 画当前圆
        BNRLine *circle = _circleInProgress[@"circle"];
        [[UIColor redColor] set];
        [self drawCircle:circle];
    }
    
    // 画所有圆
    for (BNRLine *circle in self.finishedCircle) {
        [[UIColor blackColor] set];
        [self drawCircle:circle];
    }
}

#pragma mark - touch events 触摸事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a long statement to see the order of events
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    // 判断有几个手指接触到屏幕，一个就画直线，两个就画圆
    if ([touches count] > 1) {
        // 生成两个触摸点指针 分别指向回调里的touches
        UITouch *t1 = touches.allObjects[0];
        UITouch *t2 = touches.allObjects[1];
        
        // 初始化cicle 将原点和终点 分别指定两个触点
        BNRLine *circle = [[BNRLine alloc] init];
        circle.begin = [t1 locationInView:self];
        circle.end = [t2 locationInView:self];
        
        // 为方便下次区分两个触点，调用touchbegin touchend属性分别存入字典
        _touchBeginKey = [NSValue valueWithNonretainedObject:t1];
        _touchEndKey = [NSValue valueWithNonretainedObject:t2];
        NSLog(@"touch1 key: %@, touches2 key: %@",_touchBeginKey, _touchEndKey);
        _circleInProgress[_touchBeginKey] = t1;
        _circleInProgress[_touchEndKey] = t2;
        //NSLog(@"circle dic: %@", _circleInProgress);
        
        // 为之后调用circle,将其存入字典
        _circleInProgress[@"circle"] = circle;
        //NSLog(@"circlepath is : %@", _circleInProgress[@"circle"]);
        
        
    }
    else {
        
        for (UITouch *t in touches) {
            CGPoint location = [t locationInView:self];
            
            BNRLine *line = [[BNRLine alloc] init];
            line.begin = location;
            line.end =location;
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            NSLog(@"begin key is %@", key);
            self.linesInProgress[key] = line;
        }
    }
    
    [self setNeedsDisplay];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        NSLog(@"touchesMoved key: %@",key);
        if ([_touchBeginKey isEqualToValue:key]) {
            BNRLine *circle = _circleInProgress[@"circle"];
            circle.begin = [t locationInView:self];
        }
        
        else if (_touchEndKey == key){
            BNRLine *circle = _circleInProgress[@"circle"];
            circle.end = [t locationInView:self];
        }
        
        else {
            // Let's put in a long statement to see the order of events
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            // NSLog(@"moved key is %@,", key);
            BNRLine *line = _linesInProgress[key];
            
            line.end = [t locationInView:self];
        }
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 遍历整个touches
    for (UITouch *t in touches) {
        // 生成key 用来查字典
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        NSLog(@"touchesEnded key: %@",key);
        NSLog(@"touch1 key: %@, touches2 key: %@",_touchBeginKey, _touchEndKey);
        // 如果是 两根手指触摸 那么会有相应的key
        if ([_touchBeginKey isEqualToValue:key] || [_touchEndKey isEqualToValue:key]) {
            // 调用之前一直更新的circle对象
            BNRLine *circle = _circleInProgress[@"circle"];
            // 添加到数组里
            [_finishedCircle addObject:circle];
            // 清空字典
            [_circleInProgress removeAllObjects];
            
        }
        
        else {
            // Let's put in a long statement to see the order of events
            //NSLog(@"%@", NSStringFromSelector(_cmd));
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            //NSLog(@"end key is %@", key);
            BNRLine *line = self.linesInProgress[key];
            
            [self.finishedLines addObject:line];
            [self.linesInProgress removeObjectForKey:key];
        }
    }
//    for (UITouch *t in touches) {
//        // 生成key 用来查字典
//        NSValue *key = [NSValue valueWithNonretainedObject:t];
//        NSLog(@"touchesEnded key: %@",key);
//        NSLog(@"touch1 key: %@, touches2 key: %@",_touchBeginKey, _touchEndKey);
//        // 如果是 两根手指触摸 那么会有相应的key
//        if ([_touchBeginKey isEqualToValue:key] || [_touchEndKey isEqualToValue:key]) {
//            // 调用之前一直更新的circle对象
//            BNRLine *circle = _circleInProgress[@"circle"];
//            // 添加到数组里
//            [_finishedCircle addObject:circle];
//            // 清空字典
//            [_circleInProgress removeAllObjects];
//        }
//        
//        else {
//            // Let's put in a long statement to see the order of events
//            //NSLog(@"%@", NSStringFromSelector(_cmd));
//            NSValue *key = [NSValue valueWithNonretainedObject:t];
//            //NSLog(@"end key is %@", key);
//            BNRLine *line = self.linesInProgress[key];
//            
//            [self.finishedLines addObject:line];
//            [self.linesInProgress removeObjectForKey:key];
//        }
//    }
    [self setNeedsDisplay];
    //NSLog(@"draw rect");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Let's put in a long statement to see the order of events
    //NSLog(@"%@", NSStringFromSelector(_cmd));
    
    for (UITouch *t in touches) {
        // 生成key 用来查字典
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        // 如果是 两根手指触摸 那么会有相应的key
        if ([_touchBeginKey isEqualToValue:key] || [_touchEndKey isEqualToValue:key]) {
            // 调用之前一直更新的circle对象
            BNRLine *circle = self.circleInProgress[@"circle"];
            // 添加到数组里
            [self.finishedCircle addObject:circle];
            // 清空字典
            [self.circleInProgress removeAllObjects];
        }
        else {
            
            NSValue *key = [NSValue valueWithNonretainedObject:t];
            BNRLine *line = self.linesInProgress[key];
            [self.finishedLines addObject:line];
            [self.linesInProgress removeObjectForKey:key];
        }
        
    }
    [self setNeedsDisplay];
}





@end
