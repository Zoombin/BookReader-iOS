//
//  NotificationView.m
//  BookReader
//
//  Created by 颜超 on 13-7-17.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "NotificationView.h"
#import "UIButton+BookReader.h"

@implementation NotificationView {
    UILabel *contentLabel;
    UILabel *titleLabel;
    UIButton *readButton;
}
@synthesize bShouldLoad;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [backgroundView setImage:[UIImage imageNamed:@"notification_background"]];
        [self addSubview:backgroundView];
        
        // Initialization code
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
    if ([self.delegate respondsToSelector:@selector(startReadButtonClicked)]) {
        [self.delegate startReadButtonClicked];
    }
}

- (void)showInfoWithBook:(Book *)book
    andNotificateContent:(NSString *)content
{
    self.bShouldLoad = NO;
    if (book) {
        [titleLabel setText:book.name];
        [contentLabel setText:book.describe];
    } else if ([content length] > 0) {
        [contentLabel setText:content];
    } else {
        self.bShouldLoad = YES;
    }
}

@end
