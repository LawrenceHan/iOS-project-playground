//
//  BNRFLowLayout.h
//  HomePwner
//
//  Created by Hanguang on 9/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BNRFLowLayout;

@protocol BNRFlowLayoutDelegate <NSObject>
@required
- (CGFloat)collectionView:(UICollectionView*)collectionView
                   layout:(BNRFLowLayout *)layout
 heightForItemAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface BNRFLowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) NSUInteger numberOfColumns;
@property (nonatomic, assign) CGFloat interItemSpacing;
@property (weak, nonatomic) IBOutlet id<BNRFlowLayoutDelegate> delegate;

@end
