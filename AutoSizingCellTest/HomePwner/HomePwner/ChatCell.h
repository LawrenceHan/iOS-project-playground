//
//  ChatCell.h
//  HomePwner
//
//  Created by Hanguang on 2/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *messageBubble;
@property (nonatomic, strong) YYLabel *messageLabel;

- (void)layoutWithLayout:(YYTextLayout *)layout;

@end
