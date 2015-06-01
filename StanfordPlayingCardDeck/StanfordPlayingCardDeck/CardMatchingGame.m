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
@property (readwrite, nonatomic) NSString *gameLog;

@end

@implementation CardMatchingGame {
    Class _currentDeckClass;
}

- (NSMutableArray *)cards {
    if (!_cards) _cards = [NSMutableArray new];
    return _cards;
}

- (NSString *)gameLog {
    if (!_gameLog) _gameLog = @"";
    return _gameLog;
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
                            
                            // record game log
                            NSString *log = [NSString stringWithFormat:@"Matched %@%@ for %ld points!\n",
                                            card.contents, otherCard.contents, self.score];
                            self.gameLog = [self.gameLog stringByAppendingString:log];
                        } else {
                            self.score -= MISMATCH_PENALTY;
                            otherCard.chosen = NO;
                            
                            // record game log
                            NSString *log = [NSString stringWithFormat:@"%@%@ don't match! %ld points penalty\n",
                                             card.contents, otherCard.contents, self.score];
                            self.gameLog = [self.gameLog stringByAppendingString:log];
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
                        
                        NSString *otherCardsContents = @"";
                        for (Card *otherCard in otherCards) {
                            otherCard.matched = YES;
                            otherCardsContents = [otherCardsContents stringByAppendingString:otherCard.contents];
                        }
                        
                        // record game log
                        NSString *log = [NSString stringWithFormat:@"Matched %@%@ for %ld points!\n",
                                         card.contents, otherCardsContents, self.score];
                        self.gameLog = [self.gameLog stringByAppendingString:log];
                        
                    } else {
                        self.score -= MISMATCH_PENALTY * 2;
                        
                        NSString *otherCardsContents = @"";
                        for (Card *otherCard in otherCards) {
                            otherCard.chosen = NO;
                            otherCardsContents = [otherCardsContents stringByAppendingString:otherCard.contents];
                        }
                        
                        // record game log
                        NSString *log = [NSString stringWithFormat:@"%@%@ don't match! %ld points penalty\n",
                                         card.contents, otherCardsContents, self.score];
                        self.gameLog = [self.gameLog stringByAppendingString:log];
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
    NSInteger cardsCount = self.cards.count;
    Deck *deck = [[_currentDeckClass alloc] init];
    [self.cards removeAllObjects];
    self.cards = [self cardsWithCount:cardsCount usingDeck:deck];
    self.gameLog = @"";
    self.score = 0;
}

@end
