//
//  CardMatchingGame.m
//  StanfordPlayingCardDeck
//
//  Created by Hanguang on 5/29/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "CardMatchingGame.h"

static const NSInteger MISMATCH_PENALTY = 2;
static const NSInteger MATCH_BOUNS = 4;
static const NSInteger COST_TO_CHOOSE = 1;

@interface CardMatchingGame ()
@property (readwrite, nonatomic) NSInteger score;
@property (strong, nonatomic) NSMutableArray *cards; // of cards

@end

@implementation CardMatchingGame

- (NSMutableArray *)cards {
    if (!_cards) _cards = [NSMutableArray new];
    return _cards;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck
{
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                [self.cards addObject:card];
            } else {
                @throw [NSException
                        exceptionWithName:@"Out of bounds"
                        reason:@"Init with too many cards" userInfo:nil];
                self = nil;
                break;
            }
        }
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong init method"
                                   reason:@"Use initWithCardCount:(NSUInteger)count usingDeck:(Deck *)deck]"
                                 userInfo:nil];
    return nil;
}

- (void)chooseCardAtIndex:(NSUInteger)index {
    Card *card = [self cardAtIndex:index];
    
    if (!card.isMatched) {
        if (card.isChosen) {
            card.chosen = NO;
        } else {
            // match against other card
            for (Card *otherCard in self.cards) {
                if (otherCard.isChosen && !otherCard.isMatched) {
                    NSInteger matchScore = [card match:@[otherCard]];
                    if (matchScore) {
                        self.score += matchScore * MATCH_BOUNS;
                        card.matched = YES;
                        otherCard.matched = YES;
                    } else {
                        self.score -= MISMATCH_PENALTY;
                        otherCard.chosen = NO;
                    }
                    break;
                }
            }
            card.chosen = YES;
            self.score -= COST_TO_CHOOSE;
        }
    }
}

- (Card *)cardAtIndex:(NSUInteger)index {
    return (index < self.cards.count) ? self.cards[index] : nil;
}

@end
