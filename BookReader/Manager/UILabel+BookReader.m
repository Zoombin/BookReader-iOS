//
//  UILabel+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UILabel+BookReader.h"

@implementation UILabel (BookReader)
+ (UILabel *)initLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

+ (UILabel *)accountLabelWithFrame:(CGRect)frame
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setText:@"账号:"];
    return label;
}

+ (UILabel *)passwordLabelWithFrame:(CGRect)frame
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setText:@"密码:"];
    return label;
}

+ (UILabel *)memberAccountLabelWithFrame:(CGRect)frame andAccountName:(NSString *)name
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor grayColor]];
    [label setText:[NSString stringWithFormat:@"\t\t用户名:%@",name]];
    return label;
}

+ (UILabel *)memberUserMoneyLeftWithFrame:(CGRect)frame andMoneyLeft:(NSString *)count
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor grayColor]];
    [label setText:[NSString stringWithFormat:@"\t\t账号余额:%@",count]];
    return label;
}
@end
