//
//  BNRDrawView.m
//  TouchTracker
//
//  Created by John Gallagher on 1/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "BNRDrawView.h"
#import "BNRLine.h"

@interface BNRDrawView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableDictionary *linesInProgress;
@property (nonatomic, strong) NSMutableArray *finishedLines;
@property (nonatomic, strong) UIPanGestureRecognizer *moveRecognizer;

@property (nonatomic, weak) BNRLine *selectedLine;

@end

@implementation BNRDrawView

#pragma mark - init method and attributes
- (instancetype)initWithFrame:(CGRect)r
{
    self = [super initWithFrame:r];

    if (self) {
        self.linesInProgress = [[NSMutableDictionary alloc] init];
        self.finishedLines = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor grayColor];
        self.multipleTouchEnabled = YES;
        
        // 初始化双击手势对象
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        // 手势为双击
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.delaysTouchesBegan = YES;
        [self addGestureRecognizer:doubleTapRecognizer];
        
        // 初始化手势对象，初始化为单击
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        [self addGestureRecognizer:tapRecognizer];
        
        // 初始化长按手势对象
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:pressRecognizer];
        
        // 初始化pan手势对象
        self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];
        
        // 初始化swipe手势
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
        swipeRecognizer.numberOfTouchesRequired = 3;
        [self addGestureRecognizer:swipeRecognizer];
        
    }

    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - touch recognizer 触摸事件
- (void)doubleTap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized double tap");
    
    [self.linesInProgress removeAllObjects];
    [self.finishedLines removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)tap:(UIGestureRecognizer *)gr
{
    NSLog(@"Recognized tap");
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    
    if (self.selectedLine) {
        // Make ourselves the target of menu item action messages
        [self becomeFirstResponder];
        
        // Grab the menu controller
        UIMenuController *menu = [UIMenuController sharedMenuController];
        
        // Create a new "Delete" UIMenuItem
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteLine:)];
        
        menu.menuItems = @[deleteItem];
        
        // Tell the menu where it should come from and show it
        [menu setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menu setMenuVisible:YES];
    }
    else {
        // Hide the menu if no line is selected
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
    
}

- (void)longPress:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Recognized longpress");
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        
        if (self.selectedLine) {
            [self.linesInProgress removeAllObjects];
        }
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Longpress ended");
        self.selectedLine = nil;
    }
    [self setNeedsDisplay];
        
}

- (void)moveLine:(UIPanGestureRecognizer *)gr
{
    NSLog(@"Recognized pan");
    // 根据加速度改变速的粗线
    CGPoint currentVelocity = [gr velocityInView:self];
    //NSLog(@"current velocity is %@", NSStringFromCGPoint(currentVelocity));
    CGFloat lineWidth = (currentVelocity.x + currentVelocity.y) / 7.f;
    if (lineWidth < 0) {
        lineWidth = -lineWidth;
    }
    for (BNRLine *line in [self.linesInProgress allValues]) {
        line.lineWidth = lineWidth;
    }
    
    // 判断当前点有没有选中线
    CGPoint point = [gr locationInView:self];
    self.selectedLine = [self lineAtPoint:point];
    // If we have not selected a line , wo do not do anything here
    if (!self.selectedLine) {
        //NSLog(@"No line selected");
        // 设置菜单为隐藏
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        return;
    }
    NSLog(@"Recognized pan");
    // When the pan recognizer changes its position...
    if (gr.state == UIGestureRecognizerStateChanged) {
        // How far has the pan moved?
        CGPoint translation = [gr translationInView:self];
        // Add the translation to the current begining and end points of the line
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        // Set the new begining and end points of the line
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
        // Redraw the screen
        [self setNeedsDisplay];
        
        [gr setTranslation:CGPointZero inView:self];
    }
}

- (void)showMenu:(UISwipeGestureRecognizer *)gr
{
    
}

#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    return NO;
}

#pragma mark - touch 相关方法
- (BNRLine *)lineAtPoint:(CGPoint)p
{
    // Find a line close to p
    for (BNRLine *l in self.finishedLines) {
        CGPoint start = l.begin;
        CGPoint end = l.end;
        
        //Check a few points on the line
        for (float t = 0.0; t <= 1.0; t += 0.05) {
            float x = start.x + t * (end.x - start.x);
            float y = start.y + t * (end.y - start.y);
            
            // If the tapped point is within 20points, let's return this  line
            if (hypot(x - p.x, y - p.y) < 20.0) {
                return l;
            }
        }
    }
    
    // If nothing is close enough to the tapped point, then we did not select  a line
    return nil;
}

- (void)deleteLine:(id)sender
{
    // Remove the selected line from the list of _finishedLines
    [self.finishedLines removeObject:self.selectedLine];
    
    // Redraw everything
    [self setNeedsDisplay];
}

- (void)strokeLine:(BNRLine *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    if (line.lineWidth) {
        bp.lineWidth = line.lineWidth;
    }
    else {
        bp.lineWidth = 10;
    }
    
    bp.lineCapStyle = kCGLineCapRound;

    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    [bp stroke];
}

- (void)drawRect:(CGRect)rect
{
    // Draw finished lines in black
    [[UIColor blackColor] set];
    for (BNRLine *line in self.finishedLines) {
        [self strokeLine:line];
    }

    [[UIColor redColor] set];
    for (NSValue *key in self.linesInProgress) {
        [self strokeLine:self.linesInProgress[key]];
    }
    
    // 将选中的线改变颜色
    if (self.selectedLine) {
        [[UIColor greenColor] set];
        [self strokeLine:self.selectedLine];
    }
}


#pragma mark - touch life cycle 回调
- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.selectedLine) {
        self.selectedLine = nil;
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }

    for (UITouch *t in touches) {
        CGPoint location = [t locationInView:self];

        BNRLine *line = [[BNRLine alloc] init];
        line.begin = location;
        line.end = location;

        NSValue *key = [NSValue valueWithNonretainedObject:t];
        self.linesInProgress[key] = line;
    }

    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));
    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        BNRLine *line = self.linesInProgress[key];

        line.end = [t locationInView:self];
    }

    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        BNRLine *line = self.linesInProgress[key];

        [self.finishedLines addObject:line];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    // Let's put in a log statement to see the order of events
    NSLog(@"%@", NSStringFromSelector(_cmd));

    for (UITouch *t in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:t];
        [self.linesInProgress removeObjectForKey:key];
    }

    [self setNeedsDisplay];
}

#pragma mark - testing code
- (NSInteger)numberOfLines
{
    NSInteger count = 0;
    // Check that they are non-nil before we add their counts...
    if (self.finishedLines && self.linesInProgress) {
        count = [[self.linesInProgress allKeys] count] + [self.finishedLines count];
    }
    return count;
}

@end
