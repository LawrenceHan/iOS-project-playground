//
//  BNRCollectionViewCell.m
//  HomePwner
//
//  Created by Hanguang on 9/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRCollectionViewCell.h"

@interface BNRCollectionViewCell ()
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation BNRCollectionViewCell

- (void)awakeFromNib {
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    self.selectedBackgroundView.backgroundColor = [UIColor yellowColor];
    
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

@end
