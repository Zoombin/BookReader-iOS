//
//  NotificationView.m
//  BookReader
//
//  Created by 颜超 on 13-7-17.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "BRNotificationView.h"
#import "UIButton+BookReader.h"
#import "ServiceManager.h"

@implementation BRNotificationView {
    UILabel *contentLabel;
    UILabel *titleLabel;
    UIButton *readButton;
    UIButton *closeButton;
    UIImageView *backgroundView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, frame.size.width - 2 * 15, frame.size.height)];
        [backgroundView setImage:[UIImage imageNamed:@"notification_background"]];
        [self addSubview:backgroundView];
        
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, frame.size.width, 15)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:14]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:titleLabel];
        
		contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(titleLabel.frame), frame.size.width - 40, frame.size.height - 50)];
        [contentLabel setFont:[UIFont systemFontOfSize:12]];
        [contentLabel setBackgroundColor:[UIColor clearColor]];
        [contentLabel setNumberOfLines:0];
        [contentLabel setLineBreakMode:NSLineBreakByClipping];
        [contentLabel setUserInteractionEnabled:NO];
        [self addSubview:contentLabel];
        
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setFrame:CGRectMake(0, 0, 20, 20)];
		closeButton.center = CGPointMake(CGRectGetMaxX(backgroundView.frame) - 10, CGRectGetMinY(backgroundView.frame) + 10);
        [closeButton setBackgroundImage:[UIImage imageNamed:@"notification_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(willClose) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        readButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [readButton cooldownButtonFrame:CGRectMake(CGRectGetMaxX(backgroundView.frame) - 110, CGRectGetMaxY(backgroundView.frame) - 30, 80, 20) andEnableCooldown:NO];
        [readButton addTarget:self action:@selector(startRead) forControlEvents:UIControlEventTouchUpInside];
        [readButton setTitle:@"马上阅读" forState:UIControlStateNormal];
        [readButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:readButton];
    }
    return self;
}

- (void)startRead
{
	[_delegate willRead:_notification.books[0]];
	[self close];
}

- (void)close
{
	[_notification didRead];
}

- (void)willClose
{
	[_delegate willClose];
	[self close];
}

- (void)setNotification:(BRNotification *)notification
{
	_notification = notification;
	titleLabel.text = [notification displayedTitle];
	contentLabel.text = [notification displayedContent];
	readButton.hidden = ![notification canRead];
}

@end
