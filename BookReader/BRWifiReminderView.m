//
//  BRWifiReminderCell.m
//  BookReader
//
//  Created by zhangbin on 8/11/13.
//  Copyright (c) 2013 ZoomBin. All rights reserved.
//

#import "BRWifiReminderView.h"

@implementation BRWifiReminderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, frame.size.width - 2 * 5, frame.size.height)];
		textView.userInteractionEnabled = NO;
		textView.layer.cornerRadius = 5.0f;
		textView.backgroundColor = [UIColor colorWithRed:136.0/255.0 green:65.0/255.0 blue:26.0/255.0 alpha:0.8];
		[textView setText:@"特别提示：本应用在WIFI环境下会自动下载书架内所有作品的公众章节和已订阅的VIP章节内容以便您离线阅读。在非WIFI下，本应用则仅下载开启了”自动更新“作品的章节内容，这将消耗极少的流量。"];
		textView.textColor = [UIColor whiteColor];
		textView.font = [UIFont systemFontOfSize:13];
		[self addSubview:textView];
    }
    return self;
}

@end
