//
//  BNRCell.m
//  HomePwner
//
//  Created by Hanguang on 8/24/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRCell.h"

@implementation BNRCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
//    // need to use to set the preferredMaxLayoutWidth below.
//    [self.contentView setNeedsLayout];
//    [self.contentView layoutIfNeeded];
//    
//    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
//    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
//    self.nameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.nameLabel.frame);
//    self.serialNumberLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.serialNumberLabel.frame);
//}

@end
