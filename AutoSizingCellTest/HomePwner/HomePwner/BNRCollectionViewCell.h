//
//  BNRCollectionViewCell.h
//  HomePwner
//
//  Created by Hanguang on 9/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BNRCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

-(void)setImage:(UIImage *)image;

@end
