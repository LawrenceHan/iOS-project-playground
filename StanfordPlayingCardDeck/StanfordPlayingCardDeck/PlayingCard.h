//
//  PlayingCard.h
//  StanfordPlayingCardDeck
//
//  Created by Hanguang on 5/12/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "Card.h"

@interface PlayingCard : Card

@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSArray *)validSuits;
+ (NSUInteger)maxRank;
@end
