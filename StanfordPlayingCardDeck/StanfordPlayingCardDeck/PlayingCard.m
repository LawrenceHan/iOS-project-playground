//
//  PlayingCard.m
//  StanfordPlayingCardDeck
//
//  Created by Hanguang on 5/12/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard
@synthesize suit = _suit;

- (NSInteger)match:(NSArray *)otherCards {
    NSInteger score = 0;
    
    if (otherCards.count == 1) {
        PlayingCard *otherCard = [otherCards firstObject];
        if ([self.suit isEqualToString:otherCard.suit]) {
            score = 1;
        } else if (self.rank == otherCard.rank) {
            score = 4;
        }
    } else if (otherCards.count == 2) {
        for (PlayingCard *otherCard in otherCards) {
            if ([self.suit isEqualToString:otherCard.suit]) {
                score += 1;
            } else if (self.rank == otherCard.rank) {
                score += 4;
            }
        }
        
        PlayingCard *firstCard = [otherCards firstObject];
        PlayingCard *secondCard = [otherCards lastObject];
        
        if ([self.suit isEqualToString:firstCard.suit] && [self.suit isEqualToString:secondCard.suit]) {
            score += 4;
        } else if (self.rank == firstCard.rank && self.rank == secondCard.rank) {
            score = score * 2;
        }
    }
    
    return score;
}

- (NSString *)contents {
    NSArray *rankStrings = [PlayingCard rankStrings];
    return [rankStrings[self.rank] stringByAppendingString:self.suit];
}

+ (NSArray *)validSuits {
    return @[@"♥️", @"♦️", @"♠️", @"♣️"];
}

+ (NSArray *)rankStrings {
    return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
}

+ (NSUInteger)maxRank { return [[self rankStrings] count] - 1; }

- (void)setSuit:(NSString *)suit {
    if ([[PlayingCard validSuits] containsObject:suit]) {
        _suit = suit;
    }
}

- (NSString *)suit {
    return _suit ? _suit : @"?";
}

- (void)setRank:(NSUInteger)rank {
    if (rank <= [PlayingCard maxRank]) {
        _rank = rank;
    }
}

@end
