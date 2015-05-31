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
@property (readwrite, nonatomic) GameMode currentMode;

@end

@implementation CardMatchingGame {
    Class _currentDeckClass;
}

- (NSMutableArray *)cards {
    if (!_cards) _cards = [NSMutableArray new];
    return _cards;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck
{
    self = [self initWithCardCount:count usingDeck:deck withMode:GameModeTwoCard];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck withMode:(GameMode)mode {
    self = [super init];
    
    if (self) {
        self.cards = [self cardsWithCount:count usingDeck:deck];
        self.currentMode = mode;
        if (self.cards.count) {
            _currentDeckClass = deck.class;
        } else {
            return nil;
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
            // match against other cards
            if (self.currentMode == GameModeTwoCard) {
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
            } else if (self.currentMode == GameModeThreeCard) {
                NSMutableArray *otherCards = [NSMutableArray new];
                for (Card *otherCard in self.cards) {
                    if (otherCard.isChosen && !otherCard.isMatched) {
                        [otherCards addObject:otherCard];
                    }
                }

                if (otherCards.count == 2) {
                    NSInteger matchScore = [card match:otherCards];
                    if (matchScore) {
                        self.score += matchScore * MATCH_BOUNS;
                        card.matched = YES;
                        for (Card *otherCard in otherCards) {
                            otherCard.matched = YES;
                        }
                        
                    } else {
                        self.score -= MISMATCH_PENALTY * 2;
                        for (Card *otherCard in otherCards) {
                            otherCard.chosen = NO;
                        }
                    }
                    
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

- (NSMutableArray *)cardsWithCount:(NSUInteger)count usingDeck:(Deck *)deck {
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    if (count <= 1) {
        @throw [NSException
                exceptionWithName:@"Out of bounds"
                reason:@"Cards count must greater than 1" userInfo:nil];
        return nil;
    }
    
    for (int i = 0; i < count; i++) {
        Card *card = [deck drawRandomCard];
        if (card) {
            [mutableArray addObject:card];
        } else {
            @throw [NSException
                    exceptionWithName:@"Out of bounds"
                    reason:@"Init with too many cards" userInfo:nil];
            mutableArray = nil;
            break;
        }
    }
    
    return mutableArray;
}

- (void)redeal {
    [self redealWithMode:GameModeTwoCard];
}

- (void)redealWithMode:(GameMode)mode {
    self.currentMode = mode;
    NSInteger cardsCount = self.cards.count;
    Deck *deck = [[_currentDeckClass alloc] init];
    [self.cards removeAllObjects];
    self.cards = [self cardsWithCount:cardsCount usingDeck:deck];
}

@end
