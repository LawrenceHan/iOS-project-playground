//
//  DynamicFlowLayout.m
//  HomePwner
//
//  Created by Hanguang on 9/11/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRDynamicFlowLayout.h"

@interface BNRDynamicFlowLayout ()
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableSet *visibleIndexPathsSet;
@property (nonatomic, assign) CGFloat latestDelta;

@end

@implementation BNRDynamicFlowLayout

- (instancetype)init {
    if (!(self = [super init])) return nil;
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.itemSize = CGSizeMake(44, 44);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPathsSet = [NSMutableSet set];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.itemSize = CGSizeMake(44, 44);
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPathsSet = [NSMutableSet set];
    return self;
}

- (void)resetLayout {
    [self.dynamicAnimator removeAllBehaviors];
    [self prepareLayout];
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // 创建一个比contentSize略大一圈的Rect, 用来计算有多少cell在里面
    CGRect originalRect = (CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.bounds.size};
    CGRect visibleRect = CGRectInset(originalRect, -100, -100);
    
    // 调用super方法来生成默认layout attribute
    NSArray *itemsInVisibleRectArray = [super layoutAttributesForElementsInRect:visibleRect];
    // 把所有layout attribute的indexPath放入一个NSSet里
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[itemsInVisibleRectArray valueForKey:@"indexPath"]];
    
    // 筛选出不可见的layout attribute
    NSPredicate *predicate1 = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behavior, NSDictionary *bindings) {
        BOOL currectlyVisible = [itemsIndexPathsInVisibleRectSet member:[[[behavior items] firstObject] indexPath]] != nil;
        return !currectlyVisible;
    }];
    NSArray *noLongerVisibleBehaviors = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:predicate1];
    
    // 从property里移除
    [noLongerVisibleBehaviors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] firstObject] indexPath]];
    }];
    
    // 筛选出目前可见的cell layout attribute
    NSPredicate *predicate2 = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = [self.visibleIndexPathsSet member:item.indexPath] != nil;
        return !currentlyVisible;
    }];
    NSArray *newlyVisibleItems = [itemsInVisibleRectArray filteredArrayUsingPredicate:predicate2];
    
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehavior.length = 0.0f;
        springBehavior.damping = 0.8f;
        springBehavior.frequency = 1.0f;
        
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehavior.anchorPoint.y);
            CGFloat xDistanceFromTouch = fabs(touchLocation.x - springBehavior.anchorPoint.x);
            CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
            
            if (self.latestDelta < 0) {
                center.y += MAX(self.latestDelta, self.latestDelta * scrollResistance);
            } else {
                center.y += MIN(self.latestDelta, self.latestDelta * scrollResistance);
            }
            
            item.center = center;
        }
        
        [self.dynamicAnimator addBehavior:springBehavior];
        [self.visibleIndexPathsSet addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    self.latestDelta = delta;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat yDistanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat xDistanceFromTouch = fabs(touchLocation.x - springBehaviour.anchorPoint.x);
        CGFloat scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500.0f;
        
        UICollectionViewLayoutAttributes *item = springBehaviour.items.firstObject;
        CGPoint center = item.center;
        
        if (delta < 0) {
            center.y += MAX(delta, delta * scrollResistance);
        } else {
            center.y += MIN(delta, delta * scrollResistance);
        }
        
        item.center = center;
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
