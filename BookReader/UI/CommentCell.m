//
//  CommentCell.m
//  BookReader
//
//  Created by 颜超 on 13-5-22.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"
#import "NSString+XXSY.h"

@implementation CommentCell {
    UILabel *messageLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        [messageLabel setFont:[UIFont systemFontOfSize:14]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.contentView addSubview:messageLabel];
    }
    return self;
}

- (void)setComment:(Comment *)comment
{
    CGRect cellFrame = [self frame];
    cellFrame.origin = CGPointMake(0, 0);
    [messageLabel setText:[[NSString stringWithFormat:@"%@:%@\n\n%@",comment.userName,comment.content,comment.insertTime] XXSYHandleRedundantTags]];
    [messageLabel sizeToFit];
    cellFrame.size.height =  messageLabel.frame.size.height;
    [self setFrame:cellFrame];
}

@end
