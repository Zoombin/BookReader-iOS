//
//  GiftButton.m
//  BookReader
//
//  Created by 颜超 on 13-8-6.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "GiftButton.h"
#import <QuartzCore/QuartzCore.h>

#define BorderColor     [UIColor colorWithRed:20.0/255.0 green:139.0/255.0 blue:14.0/255.0 alpha:1.0]

@implementation GiftButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn_hl"] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"member_btn_disable"] forState:UIControlStateDisabled];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        self.layer.borderColor = BorderColor.CGColor;
        [self.layer setBorderWidth:2];
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
