//
//  ChatCell.m
//  HomePwner
//
//  Created by Hanguang on 2/2/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (!self) {
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit {
    UIImage *image = [UIImage imageNamed:@"06.png"];
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    _messageBubble = [[UIImageView alloc] initWithImage:image];
    _messageBubble.size = CGSizeMake(self.bounds.size.width - 87, self.height);
    _messageBubble.top = 2;
    _messageBubble.left = 52;
    [self.contentView addSubview:_messageBubble];
    
    _messageLabel = [YYLabel new];
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.textColor = [UIColor redColor];
    _messageLabel.numberOfLines = 0;
    _messageLabel.size = CGSizeMake(self.bounds.size.width - 87, self.height);
    _messageLabel.top = 2;
    _messageLabel.left = 52;
    _messageLabel.displaysAsynchronously = YES;
    _messageLabel.ignoreCommonProperties = YES;
    [self.contentView addSubview:_messageLabel];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutWithLayout:(YYTextLayout *)layout {
    _messageBubble.size = layout.textBoundingSize;
    _messageLabel.layer.contents = nil;
    _messageLabel.size = layout.textBoundingSize;
    _messageLabel.textLayout = layout;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
