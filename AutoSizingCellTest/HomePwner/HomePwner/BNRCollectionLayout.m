//
//  BNRCollectionLayout.m
//  HomePwner
//
//  Created by Hanguang on 9/11/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#import "BNRCollectionLayout.h"

static CGFloat kItemSize = 100.0f;
#define attachmentPoint CGPointMake(CGRectGetMidX(self.collectionView.bounds), 64)

@interface BNRCollectionLayout ()
@property (nonatomic, strong) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;

@end

@implementation BNRCollectionLayout

- (instancetype)init {
    if (!(self = [super init])) return nil;
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[]];
    gravityBehaviour.gravityDirection = CGVectorMake(0, 1);
    self.gravityBehavior = gravityBehaviour;
    [self.dynamicAnimator addBehavior:gravityBehaviour];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[]];
    [self.dynamicAnimator addBehavior:collisionBehaviour];
    self.collisionBehavior = collisionBehaviour;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder])) return nil;
    
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[]];
    gravityBehaviour.gravityDirection = CGVectorMake(0, 1);
    self.gravityBehavior = gravityBehaviour;
    [self.dynamicAnimator addBehavior:gravityBehaviour];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[]];
    [self.dynamicAnimator addBehavior:collisionBehaviour];
    self.collisionBehavior = collisionBehaviour;
    
    return self;
}

- (CGSize)collectionViewContentSize {
    return self.collectionView.bounds.size;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert) {
            UICollectionViewLayoutAttributes *attributes =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:updateItem.indexPathAfterUpdate];
            attributes.frame = CGRectMake(CGRectGetMaxX(self.collectionView.frame) + kItemSize, 300, kItemSize, kItemSize);
            
            UIAttachmentBehavior *attachBehavior = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attachmentPoint];
            attachBehavior.length = 300.f;
            attachBehavior.damping = 0.4f;
            attachBehavior.frequency = 1.0f;
            [self.dynamicAnimator addBehavior:attachBehavior];
            
            [self.gravityBehavior addItem:attributes];
            [self.collisionBehavior addItem:attributes];
        }
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

@end
