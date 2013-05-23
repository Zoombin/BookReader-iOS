//
//  UILabel+BookReader.m
//  BookReader
//
//  Created by 颜超 on 13-5-8.
//  Copyright (c) 2013年 颜超. All rights reserved.
//

#import "UILabel+BookReader.h"
#import "UIColor+Hex.h"

@implementation UILabel (BookReader)
+ (UILabel *)initLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

+ (UILabel *)titleLableWithFrame:(CGRect)frame
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    return titleLabel;
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
    [label setText:[NSString stringWithFormat:@"用户名:%@",name]];
    return label;
}

+ (UILabel *)memberUserMoneyLeftWithFrame:(CGRect)frame andMoneyLeft:(NSString *)count
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:220.0/255.0 alpha:1.0]];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label setTextColor:[UIColor grayColor]];
    [label setText:[NSString stringWithFormat:@"账号余额:%@",count]];
    return label;
}

+ (UILabel *)bookStoreLabelWithFrame:(CGRect)frame
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont boldSystemFontOfSize:17]];
    [label setTextColor:[UIColor hexRGB:0xdd8e28]];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(85, 10, 18, 10)];
    [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
    [label addSubview:arrowImageView];
    return label;
 
}
@end
