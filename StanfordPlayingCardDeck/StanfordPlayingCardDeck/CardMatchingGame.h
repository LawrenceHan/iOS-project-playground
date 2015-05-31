//
//  CardMatchingGame.h
//  StanfordPlayingCardDeck
//
//  Created by Hanguang on 5/29/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

typedef enum : NSUInteger {
    GameModeTwoCard,
    GameModeThreeCard,
} GameMode;

@interface CardMatchingGame : NSObject

// Designated initializer, default is 2-card game
- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck;

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck withMode:(GameMode)mode;

- (void)chooseCardAtIndex:(NSUInteger)index;
- (Card *)cardAtIndex:(NSUInteger)index;

- (void)redeal;

@property (readonly, nonatomic) NSInteger score;
@property (nonatomic) GameMode currentMode;
@property (readonly, nonatomic) NSString *gameLog;

@end
