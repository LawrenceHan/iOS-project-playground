//
//  ViewController.m
//  CAShapelayer
//
//  Created by Hanguang on 4/22/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "ViewController.h"
#import "LHShapelayerView.h"
#import "LHCircularLoaderView.h"
#import "LHProgressView.h"

@interface ViewController ()
@property (nonatomic, strong) LHShapelayerView *shapeLayerView;
@property (nonatomic, strong) LHCircularLoaderView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.shapeLayerView = [[LHShapelayerView alloc] init];
//    _shapeLayerView.frame = CGRectMake(0, 0, 150, 150);
//    _shapeLayerView.center = self.view.center;
//    [self.view addSubview:_shapeLayerView];
//    self.maskView = [[UIView alloc] initWithFrame:self.view.bounds];
//    _maskView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:_maskView];
    self.progressView = [[LHCircularLoaderView alloc] initWithFrame:CGRectZero];
    _progressView.frame = self.imageView.bounds;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.imageView addSubview:_progressView];
    
    [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
    
}


- (void)increaseProgress {
    _progressView.indicatorProgress += 0.1f;
    if(_progressView.indicatorProgress < 1.0f)
        [self performSelector:@selector(increaseProgress) withObject:nil afterDelay:0.3f];
    else
        [self performSelector:@selector(reveal) withObject:nil afterDelay:0.4f];
}

- (void)reveal {
    [_progressView reveal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
