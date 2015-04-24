//
//  Card.m
//  StanfordPlayingCardDeck
//
//  Created by Hanguang on 4/24/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "Card.h"

@interface Card ()

@end

@implementation Card

- (NSInteger)match:(NSArray *)otherCards {
    __block NSInteger scroe = 0;
    
    [otherCards enumerateObjectsUsingBlock:^(Card *card, NSUInteger idx, BOOL *stop) {
        if ([self.contents isEqualToString:card.contents]) {
            scroe += 1;
        }
    }];
    
    return scroe;
}

@end
