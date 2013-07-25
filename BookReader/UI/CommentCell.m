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
#import "UIColor+BookReader.h"

@implementation CommentCell {
    UILabel *messageLabel;
    UILabel *nameLabel;
    UILabel *timeLabel;
    UILabel *background;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, self.contentView.frame.size.width-30-6, 20)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        [nameLabel setTextColor:[UIColor bookStoreTxtColor]];
        [nameLabel setTextAlignment:UITextAlignmentLeft];
        [self.contentView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:nameLabel.frame];
        [timeLabel setTextAlignment:UITextAlignmentRight];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [timeLabel setTextColor:[UIColor bookStoreTxtColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:timeLabel];
        
        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 25, self.contentView.frame.size.width-30-6, self.contentView.frame.size.height-20)];
        [messageLabel setFont:[UIFont systemFontOfSize:14]];
        [messageLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [messageLabel setTextColor:[UIColor bookStoreTxtColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.contentView addSubview:messageLabel];
        
        background = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(messageLabel.frame) - 2, self.contentView.frame.size.width, 2)];
        [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [background setText:@"------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"];
        [background setBackgroundColor:[UIColor clearColor]];
        [background setTextColor:[UIColor grayColor]];
        [self.contentView addSubview:background];
    }
    return self;
}

- (void)setComment:(Comment *)comment
{
    CGRect cellFrame = [self frame];
    cellFrame.origin = CGPointMake(0, 0);
    [nameLabel setText:comment.userName];
    [timeLabel setText:comment.insertTime];
    [messageLabel setText:[[comment.content XXSYHandleRedundantTags] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    [messageLabel sizeToFit];
    cellFrame.size.height =  messageLabel.frame.size.height+timeLabel.frame.size.height + 15;
    [background setFrame:CGRectMake(0, CGRectGetMaxY(messageLabel.frame)-1 + 15, background.frame.size.width, 2)];
    [self setFrame:cellFrame];
}

- (CGFloat)height
{
   return self.frame.size.height;
}

@end
