//
//  LoginSignView.m
//  BookReader
//
//  Created by 颜超 on 13-7-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "LoginReminderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoginReminderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [label setText:@"您尚未登录，请点击右上角会员图标登录！"];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:label];
		self.layer.cornerRadius = 3.0f;
        [self setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)reset
{
	self.alpha = 1.0f;
	[self performSelector:@selector(close) withObject:nil afterDelay:3.0f];
}

- (void)close
{
	[UIView animateWithDuration:0.5 animations:^(void) {
		self.alpha = 0.0f;
	}];
}

@end
