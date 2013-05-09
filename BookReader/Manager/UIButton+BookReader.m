//
//  UIButton+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UIButton+BookReader.h"
#import "UIManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIButton (BookReader)
+ (UIButton *)initButtonWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIManager hexStringToColor:@"c0683a"]];
    [button.layer setCornerRadius:4];
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [button.layer setMasksToBounds:YES];
    [button setFrame:frame];
    return button;
}

+ (UIButton *)createButtonWithFrame:(CGRect)frame
{
    UIButton *button = [self initButtonWithFrame:frame];
    return button;
}

+ (UIButton *)createMemberbuttonFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [button setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    return button;
}
@end
