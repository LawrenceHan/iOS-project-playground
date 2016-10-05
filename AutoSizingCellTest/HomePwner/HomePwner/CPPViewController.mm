//
//  CPPViewController.m
//  HomePwner
//
//  Created by Hanguang on 10/3/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "CPPViewController.h"
#include <stdio.h>
#include <iostream>

@interface CPPViewController ()

@end

@implementation CPPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadSumTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadSumTest {
    std::cout << "Enter two numbers:" << std::endl;
    int v1 = 0, v2 = 0;
    std::cin >> v1 >> v2;
    std::cout << "The sum of " << v1 << " and " << v2
               << " is " << v1 + v2 << std::endl;
}

@end
