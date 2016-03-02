//
//  IOS7ViewController.m
//  HomePwner
//
//  Created by Hanguang on 3/1/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "IOS7ViewController.h"

@interface IOS7ViewController ()

@end

@implementation IOS7ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"You've been delivered an alert"
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    [alert show];
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    picker.left = 0;
    picker.top = 0;
    picker.datePickerMode = UIDatePickerModeCountDownTimer;
    [self.view addSubview:picker];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0.0f,
                                                                  200, 118.f, 23.0f)];
    slider.value = 0.5;
    slider.minimumValue = 0.0f;
    slider.maximumValue = 1.0f;
    [self.view addSubview:slider];
    slider.minimumTrackTintColor = [UIColor redColor];
    slider.maximumTrackTintColor = [UIColor greenColor];
    slider.thumbTintColor = [UIColor blackColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"iOS SDK";
    label.font = [UIFont boldSystemFontOfSize:70.0f];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(2.0f, 2.0f);
    [label sizeToFit];
    label.left = 40;
    label.top = 240;
    [self.view addSubview:label];
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
