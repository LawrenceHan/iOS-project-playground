//
//  AutoSizingCell.m
//  HomePwner
//
//  Created by Hanguang on 8/25/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "AutoSizingCell.h"

@implementation AutoSizingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
    
    //self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.quoteLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.quoteLabel.frame);
}

@end
