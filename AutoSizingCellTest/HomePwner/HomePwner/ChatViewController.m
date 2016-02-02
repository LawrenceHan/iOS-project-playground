//
//  ChatViewController.m
//  HomePwner
//
//  Created by Hanguang on 2/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatCell.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *strings;
@property (nonatomic, strong) NSArray *layouts;

@end

@implementation ChatViewController {
    YYTextContainer *_container;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *strings = [NSMutableArray new];
    NSMutableArray *layouts = [NSMutableArray new];
    CGFloat viewWidth = self.view.bounds.size.width;
    _container = [YYTextContainer containerWithSize:CGSizeMake(viewWidth - 87, CGFLOAT_MAX)
                                             insets:UIEdgeInsetsMake(8, 11, 11, 11)];
    //    for (int i = 0; i < 10; i++) {
    //        NSString *str = [NSString stringWithFormat:@"%d Async Display Test ✺◟(∗❛ัᴗ❛ั∗)◞✺ ✺◟(∗❛ัᴗ❛ั∗)◞✺",i];
    //
    //        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    //        text.yy_font = [UIFont systemFontOfSize:16];
    //
    //        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
    //        [strings addObject:text];
    //
    //        // it better to do layout in background queue...
    //
    //        YYTextContainer *container =
    //        [YYTextContainer containerWithSize:CGSizeMake(viewWidth - 87, CGFLOAT_MAX) insets:UIEdgeInsetsMake(8, 11, 11, 11)];
    //        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:text];
    //
    //        [layouts addObject:layout];
    //    }
    
    NSMutableAttributedString *text = [NSMutableAttributedString new];
    _layouts = [NSMutableArray new];
    UIFont *font = [UIFont systemFontOfSize:16];
    
    {
        NSString *title = @"This is UIImage attachment:";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
        UIImage *image = [UIImage imageNamed:@"dribbble64_imageio"];
        
        NSMutableAttributedString *attachText =
        [NSMutableAttributedString attachmentStringWithContent:image
                                                      contentMode:UIViewContentModeCenter
                                                   attachmentSize:image.size
                                                      alignToFont:font
                                                        alignment:YYTextVerticalAlignmentCenter];
        
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
    }
    
    {
        NSString *title = @"This is UIView attachment: ";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
        
        UISwitch *switcher = [UISwitch new];
        [switcher sizeToFit];
        
        NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:switcher contentMode:UIViewContentModeCenter attachmentSize:switcher.frame.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
        
    }
    
    {
        NSString *title = @"This is Animated Image attachment:";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
        
        NSArray *names = @[@"001", @"022", @"019",@"056",@"085"];
        for (NSString *name in names) {
            NSString *path = [[NSBundle mainBundle] pathForScaledResource:name ofType:@"gif" inDirectory:@"EmoticonQQ.bundle"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            YYImage *image = [YYImage imageWithData:data scale:2];
            image.preloadAllAnimatedImageFrames = YES;
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [text appendAttributedString:attachText];
        }
        
        YYImage *image = [YYImage imageNamed:@"pia"];
        image.preloadAllAnimatedImageFrames = YES;
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
        imageView.autoPlayAnimatedImage = NO;
        [imageView startAnimating];
        
        NSMutableAttributedString *attachText =
        [NSMutableAttributedString attachmentStringWithContent:imageView
                                                   contentMode:UIViewContentModeCenter
                                                attachmentSize:imageView.size alignToFont:font
                                                     alignment:YYTextVerticalAlignmentBottom];
        [text appendAttributedString:attachText];
    }

    {
        NSString *title = @"Hi, this is a test.";
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:nil]];
        
        UIImage *image = [UIImage imageNamed:@"photo8t.jpg"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        
        NSMutableAttributedString *attachText = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:font alignment:YYTextVerticalAlignmentBottom];
        [text appendAttributedString:attachText];
        [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:nil]];
    }
    
    text.font = font;
    text.color = [UIColor redColor];
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:_container text:text];
    [layouts addObject:layout];
    
    self.strings = strings;
    self.layouts = layouts;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(ChatCell *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    YYTextLayout *layout = self.layouts[indexPath.row];
    [cell layoutWithLayout:layout];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYTextLayout *layout = self.layouts[indexPath.row];
    return layout.textBoundingSize.height + 11;
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
