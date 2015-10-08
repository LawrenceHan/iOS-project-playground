//
//  BNRPageControl.m
//  HomePwner
//
//  Created by Hanguang on 10/8/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRPageControl.h"
#import "KYAnimatedPageControl.h"

@interface BNRPageControl ()
@property (nonatomic, strong) KYAnimatedPageControl *pageControl;

@end

@implementation BNRPageControl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageControl = [[KYAnimatedPageControl alloc]initWithFrame:CGRectMake(20, 250, 280, 50)];
    self.pageControl.pageCount = 5;
    self.pageControl.unSelectedColor = [UIColor grayColor];
    self.pageControl.selectedColor = [UIColor blueColor];
    self.pageControl.shouldShowProgressLine = YES;
    self.pageControl.indicatorStyle = IndicatorStyleGooeyCircle;
    self.pageControl.indicatorSize = 20;
    self.pageControl.swipeEnable = NO;
    self.pageControl.referencedFrame = self.view.bounds;
    self.pageControl.disableBindedScrollView = YES;
    [self.view addSubview:self.pageControl];
    
}


@end
