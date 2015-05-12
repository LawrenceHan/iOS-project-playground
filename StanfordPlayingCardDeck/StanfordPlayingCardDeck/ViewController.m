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
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *flipsLabel;
@property (nonatomic) int flipsCount;
@property (strong, nonatomic) PlayingCardDeck *playingDeck;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (PlayingCardDeck *)playingDeck {
    if (!_playingDeck) _playingDeck = [[PlayingCardDeck alloc] init];
    return _playingDeck;
}

- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"flip" withExtension:@"wav"];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    }
    return _audioPlayer;
}

- (void)setFlipsCount:(int)flipsCount {
    _flipsCount = flipsCount;
    self.flipsLabel.text = [NSString stringWithFormat:@"Flips: %d", self.flipsCount];
}
- (IBAction)touchCardButton:(UIButton *)sender {
    if ([sender.currentTitle length]) {
        [sender setBackgroundImage:[UIImage imageNamed:@"cardBack"]
                          forState:UIControlStateNormal];
        [sender setTitle:@"" forState:UIControlStateNormal];
        
    } else {
        [sender setBackgroundImage:[UIImage imageNamed:@"cardFront"]
                          forState:UIControlStateNormal];
        Card *randomCard = [self.playingDeck drawRandomCard];
        [sender setTitle:randomCard.contents forState:UIControlStateNormal];
        [self.audioPlayer play];
    }
    self.flipsCount++;
}



@end
