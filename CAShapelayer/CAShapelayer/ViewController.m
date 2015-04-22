//
//  ViewController.m
//  CAShapelayer
//
//  Created by Hanguang on 4/22/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "ViewController.h"
#import "LHShapelayerView.h"

@interface ViewController ()
@property (nonatomic, strong) LHShapelayerView *shapeLayerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.shapeLayerView = [[LHShapelayerView alloc] init];
    _shapeLayerView.frame = CGRectMake(0, 0, 150, 150);
    _shapeLayerView.center = self.view.center;
    [self.view addSubview:_shapeLayerView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
