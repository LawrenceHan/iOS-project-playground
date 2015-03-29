//
//  SwapRedAndGreen.h
//  iOS8Sampler
//
//  Created by Shuichi Tsutsumi on 2014/08/18.
//  Copyright (c) 2014 Shuichi Tsutsumi. All rights reserved.
//

@import CoreImage;

@interface SwapRedAndGreen : CIFilter

@property (nonatomic, strong) CIImage *inputImage;
@property (nonatomic, copy) NSNumber *inputAmount;

@end
