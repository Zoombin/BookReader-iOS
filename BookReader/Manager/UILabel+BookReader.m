//
//  UILabel+BookReader.m
//  BookReader
//
//  Created by ZoomBin on 13-5-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "UILabel+BookReader.h"
#import "UIColor+Hex.h"

@implementation UILabel (BookReader)
+ (UILabel *)initLabelWithFrame:(CGRect)frame
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:UITextAlignmentRight];
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}

+ (UILabel *)titleLableWithFrame:(CGRect)frame
{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:frame];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
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

+ (UILabel *)bookStoreLabelWithFrame:(CGRect)frame
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setTextAlignment:UITextAlignmentLeft];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setTextColor:[UIColor whiteColor]];
    return label;
 
}
@end
