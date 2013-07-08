//
//  LoginSignView.m
//  BookReader
//
//  Created by 颜超 on 13-7-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "LoginSignView.h"

@implementation LoginSignView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [label setText:@"您尚未登录"];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont boldSystemFontOfSize:14]];
        [self addSubview:label];
        
        [self setBackgroundColor:[UIColor blackColor]];
        [self setAlpha:0.8];
        [self setUserInteractionEnabled:NO];
    }
    return self;
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
