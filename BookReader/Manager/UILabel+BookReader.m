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
@end
