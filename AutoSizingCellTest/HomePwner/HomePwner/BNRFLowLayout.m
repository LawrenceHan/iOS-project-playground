//
//  BNRFLowLayout.m
//  HomePwner
//
//  Created by Hanguang on 9/1/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRFLowLayout.h"

@interface BNRFLowLayout ()
@property (nonatomic, strong) NSMutableDictionary *lastYValueForColumn;
@property (nonatomic, strong) NSMutableDictionary *layoutInfo;

@end

@implementation BNRFLowLayout

- (void)prepareLayout {
    self.numberOfColumns = 3;
    self.interItemSpacing = 12.5;
    
    self.lastYValueForColumn = [NSMutableDictionary dictionary];
    CGFloat currentColumn = 0;
    CGFloat fullWidth = self.collectionView.frame.size.width;
    CGFloat availableSpaceExcludingPadding = fullWidth - (self.interItemSpacing * (self.numberOfColumns + 1));
    CGFloat itemWidth = availableSpaceExcludingPadding / self.numberOfColumns;
    self.layoutInfo = [NSMutableDictionary dictionary];
    NSIndexPath *indexPath;
    NSInteger numSections = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < numSections; section++) {
        
        NSInteger numItems = [self.collectionView numberOfItemsInSection:section];
        for (NSInteger item = 0; item < numItems; item++) {
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            CGFloat x = self.interItemSpacing + (self.interItemSpacing + itemWidth) * currentColumn;
            CGFloat y = [self.lastYValueForColumn[@(currentColumn)] doubleValue];
            
            CGFloat height = [((id<BNRFlowLayoutDelegate>)self.collectionView.delegate)
                              collectionView:self.collectionView
                              layout:self
                              heightForItemAtIndexPath:indexPath];
            
            itemAttributes.frame = CGRectMake(x, y, itemWidth, height);
            y += height;
            y += self.interItemSpacing;
            
            self.lastYValueForColumn[@(currentColumn)] = @(y);
            
            currentColumn ++;
            if(currentColumn == self.numberOfColumns) currentColumn = 0;
            self.layoutInfo[indexPath] = itemAttributes;
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:self.layoutInfo.count];
    
    [self.layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                         UICollectionViewLayoutAttributes *attributes,
                                                         BOOL *stop) {
        
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }];
    
    return allAttributes;
}

- (CGSize)collectionViewContentSize {
    NSUInteger currentColumn = 0;
    CGFloat maxHeight = 0;
    do {
        CGFloat height = [self.lastYValueForColumn[@(currentColumn)] doubleValue];
        if(height > maxHeight) maxHeight = height;
        currentColumn ++;
    } while (currentColumn < self.numberOfColumns);
    
    return CGSizeMake(self.collectionView.frame.size.width, maxHeight);
}

@end
