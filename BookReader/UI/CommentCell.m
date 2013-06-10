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
    UILabel *nameLabel;
    UILabel *timeLabel;
    UIView *background;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.contentView.frame.size.width-20, 20)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:12]];
        [nameLabel setTextAlignment:UITextAlignmentLeft];
        [self.contentView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:nameLabel.frame];
        [timeLabel setTextAlignment:UITextAlignmentRight];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:timeLabel];
        
        messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 20, self.contentView.frame.size.width-20, self.contentView.frame.size.height-20)];
        [messageLabel setFont:[UIFont systemFontOfSize:14]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [messageLabel setNumberOfLines:0];
        [messageLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [self.contentView addSubview:messageLabel];
        
        background = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(messageLabel.frame)-1, self.contentView.frame.size.width - 15, 0.5)];
		[background setBackgroundColor:[UIColor blackColor]];
		[self addSubview:background];
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
    cellFrame.size.height =  messageLabel.frame.size.height+timeLabel.frame.size.height;
    [background setFrame:CGRectMake(10, CGRectGetMaxY(messageLabel.frame)-1, background.frame.size.width-15, 0.5)];
    [self setFrame:cellFrame];
}

- (CGFloat)height
{
   return self.frame.size.height;
}

@end
