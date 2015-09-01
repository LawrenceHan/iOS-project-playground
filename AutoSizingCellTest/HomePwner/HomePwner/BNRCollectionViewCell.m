//
//  BNRCollectionViewCell.m
//  HomePwner
//
//  Created by Hanguang on 9/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRCollectionViewCell.h"

@implementation BNRCollectionViewCell

- (void)awakeFromNib {
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    
    [super awakeFromNib];
}

@end
