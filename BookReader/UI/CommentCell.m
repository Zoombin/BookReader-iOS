//
//  CommentCell.m
//  BookReader
//
//  Created by ZoomBin on 13-5-22.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "CommentCell.h"
#import "BRComment.h"
#import "NSString+XXSY.h"
#import "UIColor+BookReader.h"
#import "NSString+ZBUtilites.h"

@implementation CommentCell {
    UITextView *messageLabel;
    UILabel *nameLabel;
    UILabel *timeLabel;
    UILabel *line;
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
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, self.contentView.frame.size.width - 8, 20)];
        [timeLabel setTextAlignment:NSTextAlignmentRight];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [timeLabel setTextColor:[UIColor bookStoreTxtColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentView addSubview:timeLabel];
        
        messageLabel = [[UITextView alloc]initWithFrame:CGRectMake(8, 25, self.contentView.frame.size.width - 16, self.contentView.frame.size.height - 20)];
        [messageLabel setFont:[UIFont systemFontOfSize:14]];
        [messageLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin];
        [messageLabel setUserInteractionEnabled:NO];
        [messageLabel setTextColor:[UIColor bookStoreTxtColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:messageLabel];
        
		line = [UILabel dashLineWithFrame:CGRectMake(0, self.contentView.frame.size.height - 2, self.contentView.frame.size.width + 20, 2)];
		[self.contentView addSubview:line];
    }
    return self;
}

- (void)setComment:(BRComment *)comment
{
    CGRect cellFrame = [self frame];
    cellFrame.origin = CGPointMake(0, 0);
    [nameLabel setText:comment.userName];
    [timeLabel setText:comment.insertTime];
    [messageLabel setText:[[comment.content XXSYHandleRedundantTags] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [messageLabel sizeToFit];
        [messageLabel setFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y, self.contentView.frame.size.width - 16, messageLabel.frame.size.height + 5)];
    }else  {
        [messageLabel setFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y, messageLabel.frame.size.width, messageLabel.contentSize.height)];
    }
    cellFrame.size.height =  messageLabel.frame.size.height+timeLabel.frame.size.height + 15;
    [self setFrame:cellFrame];
    [line setFrame:CGRectMake(0, cellFrame.size.height - 2, self.contentView.frame.size.width + 20, 2)];
    [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (CGFloat)height
{
    return self.frame.size.height;
}

@end
