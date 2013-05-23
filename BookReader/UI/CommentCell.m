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
    UILabel *timeLabel;
    UIView *background;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width,self.contentView.frame.size.height)];
        [background setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
        [self.contentView addSubview:background];
        
        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 1, self.contentView.frame.size.width-20, self.contentView.frame.size.height)];
        [messageLabel setFont:[UIFont systemFontOfSize:14]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.contentView addSubview:messageLabel];
        
        timeLabel = [[UILabel alloc] init];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:10]];
        [self.contentView addSubview:timeLabel];
    }
    return self;
}

- (void)setComment:(Comment *)comment
{
    CGRect cellFrame = [self frame];
    cellFrame.origin = CGPointMake(0, 0);
    [messageLabel setText:[[NSString stringWithFormat:@"%@:%@",comment.userName,comment.content] XXSYHandleRedundantTags]];
    [messageLabel sizeToFit];
    [timeLabel setText:comment.insertTime];
    [timeLabel setFrame:CGRectMake(5, 1+messageLabel.frame.size.height, messageLabel.frame.size.width, 20)];
    cellFrame.size.height =  messageLabel.frame.size.height+timeLabel.frame.size.height+10;
    background.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y
                                  , cellFrame.size.width, cellFrame.size.height-10);
    [self setFrame:cellFrame];
}

@end
