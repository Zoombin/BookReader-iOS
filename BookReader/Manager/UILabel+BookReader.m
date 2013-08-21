//
//  UILabel+BookReader.m
//  BookReader
//
//  Created by ZoomBin on 13-5-8.
//  Copyright (c) 2013年 ZoomBin. All rights reserved.
//

#import "UILabel+BookReader.h"
#import "UIColor+Hex.h"
#import "NSString+ZBUtilites.h"

@implementation UILabel (BookReader)

+ (UILabel *)dashLineWithFrame:(CGRect)frame
{
	UILabel *line = [[UILabel alloc] initWithFrame:frame];
	line.text = [NSString dashLineWithLength:155];
	[line setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[line setBackgroundColor:[UIColor clearColor]];
	[line setTextColor:[UIColor grayColor]];
	return line;
}

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
    [titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
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

+ (UILabel *)bookStoreLabelWithFrame:(CGRect)frame
{
    UILabel *label = [self initLabelWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    [label setTextColor:[UIColor whiteColor]];
    return label;
 
}
@end
