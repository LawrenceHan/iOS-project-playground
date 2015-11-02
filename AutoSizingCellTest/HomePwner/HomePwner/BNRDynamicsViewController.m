//
//  BNRTestViewController.m
//  HomePwner
//
//  Created by Hanguang on 8/31/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRDynamicsViewController.h"

const CGPoint kViewPoint1 = {.x = 50, .y = 50};
const CGPoint kViewPoint2 = {.x = 200, .y = 50};

@interface BNRDynamicsViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UISnapBehavior *snapBehavior;
@property (nonatomic, strong) UIView *blueView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) UIView *yellowView;
@property (nonatomic, strong) UIView *greenView;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic) BOOL didSetupConstraints;
@end

@implementation BNRDynamicsViewController {
    CGRect _originalFrame;
}

#pragma mark - Init methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.blueView = [UIView new];
    self.blueView.backgroundColor = [UIColor blueColor];
    self.redView = [UIView new];
    self.redView.backgroundColor = [UIColor redColor];
    self.yellowView = [UIView new];
    self.yellowView.backgroundColor = [UIColor yellowColor];
    self.greenView = [UIView new];
    self.greenView.backgroundColor = [UIColor greenColor];
    
    [self.view addSubview:self.blueView];
    [self.view addSubview:self.redView];
    [self.view addSubview:self.yellowView];
    [self.view addSubview:self.greenView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [self reset:nil];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        UIView *superView = self.view;
        
        [self.blueView mas_makeConstraints:^(MASConstraintMaker *make){
            make.center.equalTo(superView);
            make.size.mas_equalTo(CGSizeMake(50.0, 50.0));
        }];
        
        [self.redView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.blueView.mas_bottom);
            make.right.equalTo(self.blueView.mas_left);
            make.width.equalTo(@100.0);
            make.height.equalTo(self.blueView.mas_height);
        }];
        
        [self.yellowView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.redView.mas_bottom).offset(10.0);
            make.height.equalTo(@20.0);
            make.left.equalTo(superView.mas_left).offset(20);
            make.right.equalTo(superView.mas_right).offset(-20);
        }];

        
        
//        // Green view is positioned 10 pt below the yellow view, aligned to the vertical axis of its superview,
//        // with its height twice the height of the yellow view and its width fixed to 150 pt
//        [self.greenView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.yellowView withOffset:10.0];
//        [self.greenView autoAlignAxisToSuperviewAxis:ALAxisVertical];
//        [self.greenView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.yellowView withMultiplier:2.0];
//        [self.greenView autoSetDimension:ALDimensionWidth toSize:150.0];
        
        [self.greenView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.equalTo(self.yellowView.mas_bottom).offset(10.0);
            make.centerX.equalTo(superView.mas_centerX);
            make.height.equalTo(self.yellowView.mas_height).multipliedBy(2.0);
            make.width.equalTo(@150.0);
        }];

        
        self.didSetupConstraints = YES;
    }
    
    [super updateViewConstraints];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - Button methods
- (IBAction)reset:(id)sender {
    [self.animator removeAllBehaviors];
    self.blueView.transform = CGAffineTransformIdentity;
    self.redView.transform = CGAffineTransformIdentity;
    self.yellowView.transform = CGAffineTransformIdentity;
    self.greenView.transform = CGAffineTransformIdentity;
    [self.blueView removeGestureRecognizer:self.panGestureRecognizer];
    [self.view setNeedsUpdateConstraints];
}

- (IBAction)snapButtonTouched:(UIButton *)sender {
    CGSize size = self.view.bounds.size;
    CGPoint randomPoint = CGPointMake(arc4random_uniform(size.width), arc4random_uniform(size.height));
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.blueView snapToPoint:randomPoint];
    snap.damping = 0.25;
    [self.animator addBehavior:snap];
    [self.animator performSelector:@selector(removeBehavior:) withObject:snap afterDelay:1.0];
}

- (IBAction)attachButtonTouched:(UIButton *)sender {
    UIAttachmentBehavior *attach1 = [[UIAttachmentBehavior alloc]
                                    initWithItem:self.blueView offsetFromCenter:UIOffsetMake(25, 25) attachedToAnchor:self.redView.center];
    UIAttachmentBehavior *attach2 = [[UIAttachmentBehavior alloc] initWithItem:self.blueView attachedToItem:self.redView];
    [self.animator addBehavior:attach1];
    [self.animator addBehavior:attach2];
    
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.redView] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(1, 0);
    [self.animator addBehavior:push];
}

- (IBAction)push:(UIButton *)sender {
    UIPushBehavior *push = [[UIPushBehavior alloc]
                            initWithItems:@[self.yellowView, self.greenView] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(0.5, 0);
    [self.animator addBehavior:push];
}

- (IBAction)gravity:(UIButton *)sender {
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.blueView]];
    gravity.action = ^{
        NSLog(@"Current point: %@", NSStringFromCGPoint(self.blueView.center));
    };
    [self.animator addBehavior:gravity];
}

- (IBAction)collision:(id)sender {
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.blueView, self.redView, self.yellowView, self.greenView]];
    collision.collisionMode = UICollisionBehaviorModeEverything;
    collision.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:collision];
    
    UIPushBehavior *push1 = [[UIPushBehavior alloc] initWithItems:@[self.blueView] mode:UIPushBehaviorModeInstantaneous];
    UIPushBehavior *push2 = [[UIPushBehavior alloc] initWithItems:@[self.redView] mode:UIPushBehaviorModeInstantaneous];
    UIPushBehavior *push3 = [[UIPushBehavior alloc] initWithItems:@[self.yellowView] mode:UIPushBehaviorModeInstantaneous];
    UIPushBehavior *push4 = [[UIPushBehavior alloc] initWithItems:@[self.greenView] mode:UIPushBehaviorModeInstantaneous];
    
    push1.pushDirection = CGVectorMake(1, 0);
    push2.pushDirection = CGVectorMake(0, 1);
    push3.pushDirection = CGVectorMake(-1, 0);
    push4.pushDirection = CGVectorMake(0, -1);
    
    [self.animator addBehavior:push1];
    [self.animator addBehavior:push2];
    [self.animator addBehavior:push3];
    [self.animator addBehavior:push4];
}

- (IBAction)drag:(id)sender {
    [self.animator addBehavior:[[UISnapBehavior alloc]
                                initWithItem:self.blueView snapToPoint:self.blueView.center]];
    [self.blueView addGestureRecognizer:self.panGestureRecognizer];
}

- (IBAction)dropPanGesture:(UIPanGestureRecognizer *)gesture {
//    if (gesture.state == UIGestureRecognizerStateBegan) {
//        CGPoint squareCenterPoint = CGPointMake(self.blueView.center.x, self.blueView.center.y);
//        UIOffset offset = UIOffsetMake(0, 0);
//        CGPoint touchPoint = [gesture locationInView:self.view];
//        
//        if (CGRectContainsPoint(self.blueView.frame, touchPoint)) {
//            UIAttachmentBehavior *attach = [[UIAttachmentBehavior alloc]
//                                            initWithItem:self.blueView offsetFromCenter:offset attachedToAnchor:squareCenterPoint];
//            self.attachmentBehavior = attach;
//            [self.animator addBehavior:attach];
//        }
//    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _originalFrame = self.blueView.frame;
        self.blueView.frame = CGRectMake(_originalFrame.origin.x, _originalFrame.origin.y,
                                         _originalFrame.size.width + 10, _originalFrame.size.height + 10);
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        [self dragToPoint:[gesture locationInView:self.view]];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled) {
        [self stopDragging];
    }
}

- (void)dragToPoint:(CGPoint)point {
    [self.animator removeBehavior:self.snapBehavior];
    self.snapBehavior = [[UISnapBehavior alloc] initWithItem:self.blueView
                                                 snapToPoint:point];
    self.snapBehavior.damping = .25;
    [self.animator addBehavior:self.snapBehavior];
}

- (void)stopDragging {
    [self.animator removeBehavior:self.snapBehavior];
    self.snapBehavior = nil;
    self.blueView.transform = CGAffineTransformIdentity;
    self.blueView.frame = _originalFrame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
