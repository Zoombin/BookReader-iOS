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
    Book *bookObject;
    UIImageView *backgroundView;
}
@synthesize bShouldLoad;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, frame.size.width - 2 * 5, frame.size.height)];
        [backgroundView setImage:[UIImage imageNamed:@"notification_background"]];
        [self addSubview:backgroundView];
        
        self.bShouldLoad = YES;
         titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, frame.size.width, 15)];
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
        [closeButton setFrame:CGRectMake(frame.size.width - 22, 4, 20, 20)];
        [closeButton setBackgroundImage:[UIImage imageNamed:@"notification_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        
        readButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [readButton cooldownButtonFrame:CGRectMake(CGRectGetMaxX(contentLabel.frame) - 80, CGRectGetMaxY(contentLabel.frame), 80, 20) andEnableCooldown:NO];
        [readButton addTarget:self action:@selector(startRead) forControlEvents:UIControlEventTouchUpInside];
        [readButton setTitle:@"马上阅读" forState:UIControlStateNormal];
        [readButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:readButton];
    }
    return self;
}

- (void)startRead
{
	[self.delegate startReadButtonClicked:bookObject];
}

- (void)close
{
	[self.delegate closeButtonClicked];
}

- (void)showInfoWithBook:(Book *)book
    andNotificateContent:(NSString *)content
{
    self.bShouldLoad = NO;
    if (book) {
        [titleLabel setText:book.name];
        [contentLabel setText:book.describe];
        [ServiceManager saveNotificationContent:book.describe];
        bookObject = book;
    } else if ([content length] > 0) {
        [readButton setHidden:YES];
        [contentLabel setText:content];
        [ServiceManager saveNotificationContent:content];
    } else {
        self.bShouldLoad = YES;
    }
}

@end
