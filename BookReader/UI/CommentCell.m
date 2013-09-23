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

#define gap 8
#define doubleGap (2 * gap)

@implementation CommentCell {
    UITextView *messageLabel;
    UILabel *nameLabel;
    UILabel *timeLabel;
    UILabel *line;
	UITextView *authorReplyLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(gap, 4, self.contentView.frame.size.width - 30 - 6, 20)];
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
        
        messageLabel = [[UITextView alloc]initWithFrame:CGRectMake(gap, 25, self.contentView.frame.size.width - doubleGap, 0)];
        [messageLabel setFont:[UIFont systemFontOfSize:14]];
        [messageLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin];
        [messageLabel setUserInteractionEnabled:NO];
        [messageLabel setTextColor:[UIColor bookStoreTxtColor]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:messageLabel];
		
		authorReplyLabel = [[UITextView alloc] initWithFrame:CGRectMake(gap, 25, self.contentView.frame.size.width - doubleGap, 0)];
		[authorReplyLabel setFont: [UIFont systemFontOfSize:14]];
		[authorReplyLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin];
		[authorReplyLabel setUserInteractionEnabled:NO];
		[authorReplyLabel setTextColor:[UIColor bookStoreTxtColor]];
		[authorReplyLabel setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:authorReplyLabel];
        
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
	
	if (comment.authorReply.length) {
		
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"firstsecondthird"];
		[string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,5)];
		[string addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(5,6)];
		[string addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(11,5)];
		
		NSMutableString *authorReplyString = [[NSMutableString alloc] initWithString:@"作者回复:"];
		[authorReplyString appendString:[[comment.authorReply XXSYHandleRedundantTags] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
		
		NSMutableAttributedString *displayed = [[NSMutableAttributedString alloc] initWithString:authorReplyString];
		NSRange range = NSMakeRange(0, 5);
		[displayed addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:range];
		range.location = 5;
		range.length = authorReplyString.length - range.location;
		[displayed addAttribute:NSForegroundColorAttributeName value:[UIColor bookStoreTxtColor] range:range];
		
		[authorReplyLabel setAttributedText:displayed];
	}
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [messageLabel sizeToFit];
        [messageLabel setFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y, self.contentView.frame.size.width - doubleGap, messageLabel.frame.size.height + 5)];
		
		[authorReplyLabel sizeToFit];
		[authorReplyLabel setFrame:CGRectMake(authorReplyLabel.frame.origin.x, CGRectGetMaxY(messageLabel.frame) - 10, self.contentView.frame.size.width - doubleGap, authorReplyLabel.frame.size.height + 5)];
    }else  {
        [messageLabel setFrame:CGRectMake(messageLabel.frame.origin.x, messageLabel.frame.origin.y, messageLabel.frame.size.width, messageLabel.contentSize.height)];
		
		[authorReplyLabel setFrame:CGRectMake(authorReplyLabel.frame.origin.x, CGRectGetMaxY(messageLabel.frame) - 10, self.contentView.frame.size.width, authorReplyLabel.contentSize.height)];
    }
    cellFrame.size.height =  messageLabel.frame.size.height + timeLabel.frame.size.height + authorReplyLabel.frame.size.height;
    [self setFrame:cellFrame];
    [line setFrame:CGRectMake(0, cellFrame.size.height - 2, self.contentView.frame.size.width + 20, 2)];
    [line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}

- (CGFloat)height
{
    return self.frame.size.height;
}

@end
