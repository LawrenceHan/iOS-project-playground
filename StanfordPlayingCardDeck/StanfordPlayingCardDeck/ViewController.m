//
//  ViewController.m
//  StanfordPlayingCardDeck
//
//  Created by Hanguang on 4/24/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardDeck.h"
#import "PlayingCard.h"
#import "CardMatchingGame.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cardButtons;
@property (strong, nonatomic) PlayingCardDeck *playingDeck;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) CardMatchingGame *game;
@end

@implementation ViewController {
    BOOL _defaultCardBack;
}

- (CardMatchingGame *)game {
    if (!_game) _game = [[CardMatchingGame alloc]
                         initWithCardCount:self.cardButtons.count usingDeck:[self createDeck]];
    return _game;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _defaultCardBack = YES;
}

- (Deck *)createDeck {
    return [[PlayingCardDeck alloc] init];
}


- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"flip" withExtension:@"wav"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    }
    return _audioPlayer;
}

- (IBAction)touchCardButton:(UIButton *)sender {
    NSInteger cardIndex = [self.cardButtons indexOfObject:sender];
    [self.game chooseCardAtIndex:cardIndex];
    [self updateUI];
}
- (IBAction)redealTouched:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"Re-deal")
                                                    message:LS(@"Are you sure you want to re-deal?")
                                                   delegate:self cancelButtonTitle:LS(@"NO")
                                          otherButtonTitles:LS(@"OK"), nil];
    alert.tag = 101;
    [alert show];
}

#pragma mark - Methods
- (void)updateUI {
    for (UIButton *cardButton in self.cardButtons) {
        NSInteger cardIndex = [self.cardButtons indexOfObject:cardButton];
        Card *card = [self.game cardAtIndex:cardIndex];
        [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
        [cardButton setBackgroundImage:[self backgroundImageForCard:card]
                              forState:UIControlStateNormal];
        cardButton.enabled = !card.isMatched;
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %ld", self.game.score];
}

- (NSString *)titleForCard:(Card *)card {
    return card.isChosen ? card.contents : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card {
    NSString *cardback = _defaultCardBack ? @"cardback_01" : @"cardback_02";
    return [UIImage imageNamed:card.isChosen ? @"cardFront" : cardback];
}

- (void)redeal {
    [self.game redeal];
    _defaultCardBack = !_defaultCardBack;
    [self updateUI];
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            [self redeal];
        }
    }
    
}

@end
