//
//  ViewController.m
//  Attributor
//
//  Created by Hanguang on 8/3/15.
//  Copyright (c) 2015 Hanguang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UILabel *headline;
@property (weak, nonatomic) IBOutlet UIButton *outlineButton;
@property (weak, nonatomic) IBOutlet UIButton *unlineButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:self.outlineButton.currentTitle];
    [attrTitle setAttributes:@{NSStrokeWidthAttributeName:@3,
                               NSStrokeColorAttributeName:self.outlineButton.tintColor}
                       range:NSMakeRange(0, attrTitle.length)];
    [self.outlineButton setAttributedTitle:attrTitle forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self usePerferredFonts];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredFontsChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)preferredFontsChanged:(NSNotification *)notification {
    [self usePerferredFonts];
}

- (void)usePerferredFonts {
    UIFont *preferredHeadline = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    UIFont *preferredBody = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.body.font = [UIFont fontWithName:self.body.font.fontName size:preferredBody.pointSize];
    self.headline.font = [UIFont fontWithName:self.body.font.fontName size:preferredHeadline.pointSize];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (IBAction)changeBodySelectionColorToMatchBackgroundOfButton:(UIButton *)sender {
    [self.body.textStorage addAttribute:NSForegroundColorAttributeName value:sender.backgroundColor range:self.body.selectedRange];
}

- (IBAction)outlineBodySelection:(id)sender {
    [self.body.textStorage addAttributes:@{NSStrokeWidthAttributeName:@-3, NSStrokeColorAttributeName:[UIColor blackColor]} range:self.body.selectedRange];
}

- (IBAction)UnoutlineSelection:(id)sender {
    [self.body.textStorage removeAttribute:NSStrokeWidthAttributeName range:self.body.selectedRange];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
